with source as (
    select * from {{ source('raw', 'repositories') }}
),

renamed as (
    select
        -- Primary key
        id as repository_id,

        -- Repository info
        name as repository_name,
        full_name as repository_full_name,
        description,
        html_url as repository_url,

        -- Owner info
        owner.login as owner_login,
        owner.type as owner_type,

        -- Repository type
        private as is_private,
        fork as is_fork,

        -- Metrics
        stargazers_count as stars_count,
        forks_count,
        open_issues_count,
        watchers_count,

        -- Technical details
        language as primary_language,
        default_branch,

        -- Timestamps
        created_at as repository_created_at,
        updated_at as repository_updated_at,
        pushed_at as last_pushed_at,

        -- Metadata
        _airbyte_extracted_at as loaded_at

    from source
)

select * from renamed
