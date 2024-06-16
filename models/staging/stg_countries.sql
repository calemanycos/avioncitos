{{ config(materialized="table") }}

with
    base as (select * from {{ ref("base_countries") }}),

    transformed as (
        select
            country_id,
            iata_country,
            country_name,
            _fivetran_synced,
            _fivetran_deleted

        from base
    )

select *
from transformed