{{ config(materialized="table") }}

with
    base as (select * from {{ ref("base_airlines") }}),

    transformed as (
        select
            airline_id,
            airline_iata,
            airline_name,
            _fivetran_synced,
            _fivetran_deleted

        from base
        where _fivetran_deleted = 'false'
    )

select *
from transformed