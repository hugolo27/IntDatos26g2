import os
import time
import subprocess
from pathlib import Path
from typing import Optional

import httpx
from dotenv import load_dotenv
from prefect import flow, task, get_run_logger

load_dotenv()

AIRBYTE_HOST = os.getenv("AIRBYTE_HOST", "localhost")
AIRBYTE_PORT = os.getenv("AIRBYTE_PORT", "8000")
AIRBYTE_USERNAME = os.getenv("AIRBYTE_USERNAME", "airbyte")
AIRBYTE_PASSWORD = os.getenv("AIRBYTE_PASSWORD", "password")
AIRBYTE_CONNECTION_ID = os.getenv("AIRBYTE_CONNECTION_ID")
DBT_PROJECT_DIR = Path(os.getenv("DBT_PROJECT_DIR", "/Users/hugolopez/mi_proyecto_dbt"))
DBT_PROFILES_DIR = Path(os.getenv("DBT_PROFILES_DIR", "/Users/hugolopez/.dbt"))
DBT_EXECUTABLE = "/Users/hugolopez/dbt-env/bin/dbt"


@task(name="Extract and Load with Airbyte", retries=2, retry_delay_seconds=30)
def extract_and_load():
    logger = get_run_logger()
    base_url = f"http://{AIRBYTE_HOST}:{AIRBYTE_PORT}/api/v1"
    logger.info(f"Triggering Airbyte sync for connection: {AIRBYTE_CONNECTION_ID}")

    with httpx.Client(timeout=30, auth=(AIRBYTE_USERNAME, AIRBYTE_PASSWORD)) as client:
        response = client.post(
            f"{base_url}/connections/sync",
            json={"connectionId": AIRBYTE_CONNECTION_ID}
        )
        if response.status_code == 409:
            logger.warning("Sync already running, fetching job id...")
            jobs_resp = client.post(
                f"{base_url}/jobs/list",
                json={"configTypes": ["sync"], "configId": AIRBYTE_CONNECTION_ID}
            )
            job_id = jobs_resp.json()["jobs"][0]["job"]["id"]
        else:
            response.raise_for_status()
            job_id = response.json()["job"]["id"]

        logger.info(f"Polling job {job_id}...")
        while True:
            status_resp = client.post(f"{base_url}/jobs/get", json={"id": job_id})
            status = status_resp.json()["job"]["status"]
            logger.info(f"Job status: {status}")
            if status == "succeeded":
                logger.info("Airbyte sync completed successfully")
                return job_id
            elif status in ("failed", "cancelled"):
                raise RuntimeError(f"Airbyte sync failed with status: {status}")
            time.sleep(10)


@task(name="Transform with dbt")
def transform(select: Optional[str] = None):
    logger = get_run_logger()
    logger.info("Running dbt models...")

    cmd = [DBT_EXECUTABLE, "run"]
    if select:
        cmd += ["--select", select]
    cmd += ["--project-dir", str(DBT_PROJECT_DIR), "--profiles-dir", str(DBT_PROFILES_DIR)]

    result = subprocess.run(cmd, capture_output=True, text=True)
    logger.info(result.stdout)
    if result.returncode != 0:
        logger.error(result.stderr)
        raise RuntimeError("dbt run failed")
    logger.info("dbt models completed successfully")


@task(name="Test data quality with dbt")
def test_data(select: Optional[str] = None):
    logger = get_run_logger()
    logger.info("Running dbt tests...")

    cmd = [DBT_EXECUTABLE, "test"]
    if select:
        cmd += ["--select", select]
    cmd += ["--project-dir", str(DBT_PROJECT_DIR), "--profiles-dir", str(DBT_PROFILES_DIR)]

    result = subprocess.run(cmd, capture_output=True, text=True)
    logger.info(result.stdout)
    if result.returncode != 0:
        logger.error(result.stderr)
        raise RuntimeError("dbt tests failed")
    logger.info("All dbt tests passed")


@flow(name="Ecommerce ELT Pipeline")
def ecommerce_pipeline(
    run_extract: bool = True,
    run_transform: bool = True,
    run_tests: bool = True,
    dbt_select: Optional[str] = None
):
    logger = get_run_logger()
    logger.info("Starting Ecommerce ELT Pipeline")

    if run_extract:
        extract_and_load()

    if run_transform:
        transform(select=dbt_select)

    if run_tests:
        test_data(select=dbt_select)

    logger.info("Pipeline completed successfully!")
    return {"status": "success"}


if __name__ == "__main__":
    # Ejecutar solo dbt (sin Airbyte) para demo
    ecommerce_pipeline(run_extract=False, run_transform=True, run_tests=True)
