with fb_cte (date, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value, url_parameters) as
(
	select  fabd.ad_date , fc.campaign_name,fa.adset_name, coalesce(fabd.spend,0) spend, coalesce(fabd.impressions,0) impressions, 
	coalesce(fabd.reach,0) reach, coalesce(fabd.clicks,0) clicks, coalesce(fabd.leads,0) leads,coalesce(fabd.value,0) value, 
	lower(fabd.url_parameters) "url parameters"
	from facebook_ads_basic_daily as fabd 
	left join facebook_adset as fa on fa.adset_id = fabd.adset_id 
	left join facebook_campaign as fc on fc.campaign_id = fabd.campaign_id 	
), 
union_google_fb_cte as(
	select * from fb_cte
	union all
	select * from google_ads_basic_daily 
)
select date, coalesce (url_parameters,' ') as utm_campaing,sum(spend) spend, sum(impressions) impressions,
sum(clicks) clicks, sum(value) value, round(sum(spend)::numeric /sum(clicks),2) as CPC, round(sum(spend)::numeric/sum(impressions) *1000,2) as CPM,
round(sum(clicks)::numeric/sum(impressions)*100,2) as CTR, round(((sum(value)-sum(spend))/sum(spend)::numeric*100),2) as "ROMI"
from union_google_fb_cte
where clicks > 0 
group by date,url_parameters 
order by "ROMI" desc 