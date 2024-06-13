{{ config(materialized='table') }}

with source as (

    select * from {{ source('openflights', 'airports') }}

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
        source

    from source

)

select * from renamed
