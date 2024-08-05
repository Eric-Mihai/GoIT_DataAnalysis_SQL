with all_ads_data as (
	select fabd.ad_date, fc.campaign_name, fa.adset_name, fabd.spend, fabd.impressions, fabd.reach, fabd.clicks, fabd.leads, fabd.value
	from facebook_ads_basic_daily fabd 
	left join facebook_adset fa on fa.adset_id  = fabd.adset_id 
	left join facebook_campaign fc on fc.campaign_id  = fabd.campaign_id 
	
	union all
	
	select ad_date, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value
	from google_ads_basic_daily gabd
), 
top_campaign as (
	select 
		campaign_name, 
		sum(spend) as total_spend, 
		((sum(value)::numeric - sum(spend))/sum(spend))*100 as romi
	from all_ads_data aad
	where spend > 0
	group by 1
	having sum(spend) >= 500000
	order by 3 desc
	limit 1
)
select 
	aad.adset_name,
	sum(spend) as total_spend, 
	sum(value) as total_value, 
	((sum(value)::numeric - sum(spend))/sum(spend))*100 as romi
from all_ads_data aad
join top_campaign tc on tc.campaign_name = aad.campaign_name
where spend > 0
group by 1
order by 4 desc;