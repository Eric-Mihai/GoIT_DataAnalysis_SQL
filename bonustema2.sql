with google_facebook_ads as (
	select
		fabd.ad_date,
		fc.campaign_name,
		fa.adset_name,
		fabd.spend,
		fabd.impressions,
		fabd.reach,
		fabd.clicks,
		fabd.leads,
		fabd.value
	from
		public.facebook_ads_basic_daily fabd
	left join
		public.facebook_campaign fc on fabd.campaign_id = fc.campaign_id
	left join
		public.facebook_adset fa on fabd.adset_id = fa.adset_id
	union all
	select
		ad_date,
		campaign_name,
		adset_name,
		spend,
		impressions,
		reach,
		clicks,
		leads,
		value
	from
		public.google_ads_basic_daily gabd
	order by
		ad_date
)
select
	campaign_name,
	sum(spend) as total_cost,
	sum(impressions) as numar_impresii,
	sum(clicks) as numar_clickuri,
	sum(value) as valoarea_totala_conversie,
	cast ((sum(value)-sum(spend)) as float)/nullif (sum(spend),0)*100 as ROMI
from
	google_facebook_ads
group by
	campaign_name
having
sum(spend) > 500000
order by
romi desc
limit 1