{{ config(materialized="table") }}

with
    source as (select * from {{ source("SNOWFLAKE_DB_OPENFLIGHTS", "airports") }}),

    renamed as (

        select
             {{ dbt_utils.generate_surrogate_key(["airport_id","Iata","icao"]) }} AS airport_id,
            trim(airport_name) as airport_name,
            trim(city) as city,
            trim(country) as country_name,
            coalesce(iata,'Unknown') as airport_iata,
            coalesce(icao,'Unknown') as airport_icao,
            cast(latitude as float) as latitude,
            cast(longitude as float) as longitude,
            cast(altitude_ft as integer) as altitude_ft,
            cast(hours_utc_offset as integer) as hours_utc_offset,
            trim(zona_horaria) as zona_horaria,
            trim(tz_timezone) as tz_timezone,
            trim(type) as type,
            trim(source) as source,
            cast(_fivetran_synced as timestamp) as _fivetran_synced,
            cast(_fivetran_deleted as boolean) as _fivetran_deleted
        from source
       

    )

select *
from renamed
