/*
Cleaning Data using SQL Queries

Skills used:  Converting Data Types, alter and update table, Joins, ,Splitting a column into parts, Case statements, CTE's, Windows Functions, Aggregate Functions

dataset: https://www.kaggle.com/tmthyjames/nashville-housing-data
*/


Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- (01) Standardize Date Format

Select SaleDate, CONVERT(date,saledate)
From NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)
	
	-- OR -- if it doesn't Update properly

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- (02) Populate Property Address data where initially it is null

-- finding null values and duplicate ParcelId
select *
from [dbo].[NashvilleHousing]
--where [PropertyAddress] is null
order by ParcelID

-- performing self join to find null addresses and then getting values for them
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

-- update dataset with new found values for previously null addresses
update a 
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- (03) Breaking out Address into Individual Columns (Address, City, State)

-- Slitting PropertyAddress
select PropertyAddress
from NashvilleHousing

select 
SUBSTRING( PropertyAddress, 1,  CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1,
  LEN(PropertyAddress)) as City 
from NashvilleHousing

-- adding new PropertySplit columns to dataset
alter table NashvilleHousing
add PropertySplitAddress nvarchar(100);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING( PropertyAddress, 1,  CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(100);

update NashvilleHousing
set PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1,
  LEN(PropertyAddress))

-- Splitting OwnerAddress
select OwnerAddress
from NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
-- parsname only works for '.' an not for ','
from NashvilleHousing

-- adding new OwnerSplit columns to dataset
alter table NashvilleHousing
add OwnerSplitAddress nvarchar(100);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(100);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(100);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- (04) Change Y and N to Yes and No in "Sold as Vacant" field

-- getting all distinct values in SoldAsVacant column

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

-- change all undesired values
select SoldAsVacant,
	case when SoldAsVacant = 'N' then 'No'
		 when SoldAsVacant = 'Y' then 'Yes'
		 else SoldAsVacant
		 end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'N' then 'No'
						 when SoldAsVacant = 'Y' then 'Yes'
						 else SoldAsVacant
						 end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- (05) Remove Duplicates

--select duplicates
WITH RowNumCTE as
(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by 
					UniqueId
				 ) as row_num
from NashvilleHousing
)

select *
from RowNumCTE
where row_num > 1

--delete duplicates
WITH RowNumCTE as
(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by 
					UniqueId
				 ) as row_num
from NashvilleHousing
)

DELETE
from RowNumCTE
where row_num > 1

---------------------------------------------------------------------------------------------------------

-- (06) Delete Unused Columns

Select *
From NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

