SELECT
  * REPLACE (
    (
      SELECT AS STRUCT
        jsonPayload.* REPLACE (
          (
            SELECT AS STRUCT
              jsonPayload.fields.* EXCEPT (device_id, user_id),
              TO_HEX(SHA256(jsonPayload.fields.user_id)) AS user_id,
              TO_HEX(SHA256(jsonPayload.fields.device_id)) AS device_id
          ) AS fields
        )
    ) AS jsonPayload
  )
FROM
  `moz-fx-fxa-prod-0712.fxa_prod_logs.docker_fxa_content_20*`
WHERE
  jsonPayload.type = 'amplitudeEvent'
  AND jsonPayload.fields.event_type IS NOT NULL
  -- FXA-6593: the partitioned version of the table
  -- seems to be missing some data.
  -- For now reverting this query to the sharded version
  -- Once the issue has been resolves:
  -- 1. uncomment the DATE(...) = @submission_date line
  -- 2. Remove the _TABLE_SUFFIX line below
  -- 3. Change source table to be `docker_fxa_content`
  -- AND DATE(`timestamp`) = @submission_date
  AND _TABLE_SUFFIX = FORMAT_DATE('%y%m%d', @submission_date)
