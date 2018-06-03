CREATE MATERIALIZED VIEW annual_route_ridership
AS
SELECT extract(year from summary_begin_date) AS year, route_number, direction, service_key, SUM(ons) AS total_ons, SUM(offs) AS total_offs
	FROM public.passenger_census
GROUP BY year, route_number, direction, service_key
ORDER BY year, route_number, direction;