with source as (
    select * from {{ source('raw', 'commits') }}
),

renamed as (
    select
        -- Primary key
        sha as commit_sha,

        -- Commit info
        commit.message as commit_message,
        commit.comment_count as comment_count,

        -- Author info
        commit.author.name as author_name,
        commit.author.email as author_email,
        commit.author.date as authored_at,

        -- Committer info
        commit.committer.name as committer_name,
        commit.committer.email as committer_email,
        commit.committer.date as committed_at,

        -- URLs
        html_url as commit_url,

        -- Repository reference
        repository,

        -- Metadata
        _airbyte_extracted_at as loaded_at

    from source
)

select * from renamed
