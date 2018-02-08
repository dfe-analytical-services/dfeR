Use PDR

GO

Select  
AcademicYear census_year,
[Government Office Region] region_code,
case  
	when NCYearActual in ('R','1','2','3','4','5','6') then 'Primary'
	when NCYearActual in ('7','8','9','10','11','12','13','14') then 'Secondary'
	else NULL
end phase,
count(*) pupil_headcount
from [Tier1].[CensusSeasonSSA_MasterView]
where CensusTerm = 'Spring'
and 
[Government Office Region] like 'E1%'
and
NCYearActual in ('R','1','2','3','4','5','6','7','8','9','10','11','12','13','14')
group by
AcademicYear,
[Government Office Region],
case 
	when NCYearActual in ('R','1','2','3','4','5','6') then 'Primary'
	when NCYearActual in ('7','8','9','10','11','12','13','14') then 'Secondary'
	else NULL
end
