{{ config(materialized='table') }}

with source as (

    select * from {{ source('SNOWFLAKE_DB_OPENFLIGHTS', 'airports') }}

),

renamed as (

    select
        airport_id,
        airport_name,
        city,
        country,
        iata,
        icao,
        latitude,
        longitude,
        altitude_ft,
        hours_utc_offset,
        zona_horaria,
        tz_timezone,
        type,
        source,
        _fivetran_synced,
        _fivetran_deleted
 
    from source
   WHERE _fivetran_deleted = FALSE

)

select * from renamed
