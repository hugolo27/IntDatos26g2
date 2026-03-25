with source as (
    select * from {{ source('raw', 'issues') }}
),

renamed as (
    select
        -- Primary key
        id as issue_id,
        number as issue_number,

        -- Issue info
        title as issue_title,
        state as issue_state,
        body as issue_description,
        html_url as issue_url,

        -- Author info
        user.login as author_login,
        user.type as author_type,

        -- Repository reference
        repository_url,

        -- Metrics
        comments as comments_count,

        -- Labels
        labels,

        -- Timestamps
        created_at as issue_created_at,
        updated_at as issue_updated_at,
        closed_at as issue_closed_at,

        -- Metadata
        _airbyte_extracted_at as loaded_at

    from source
)

select * from renamed
