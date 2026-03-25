-- Test: Commit timestamp should not be earlier than authored timestamp
-- This test fails if it returns any rows

select
    commit_sha,
    author_name,
    authored_at,
    committed_at
from {{ ref('stg_commits') }}
where committed_at < authored_at
   or authored_at is null
   or committed_at is null
