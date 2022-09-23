select * from NashvilleHousing

--- Standardize sale date
select saleDateConverted, CONVERT(Date,SaleDate)
from NashvilleHousing


update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted date;


update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate);


---Populate property address
select *
from NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

select t1.ParcelID, t1.PropertyAddress, t2.PropertyAddress, ISNULL(t1.propertyAddress,t2.propertyAddress)
from NashvilleHousing as t1
join NashvilleHousing as t2
ON t1.ParcelID = t2.ParcelID AND t1.[UniqueID ] <> t2.[UniqueID ]
where t1.PropertyAddress is null


update t1
SET PropertyAddress = ISNULL(t1.propertyAddress,t2.propertyAddress)
FROM NashvilleHousing as t1
join NashvilleHousing as t2
ON t1.ParcelID = t2.ParcelID 
AND t1.[UniqueID ] <> t2.[UniqueID ]
where t1.PropertyAddress is null



--- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
from NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) AS Street
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertyStreet Nvarchar(255);

update NashvilleHousing
set PropertyStreet = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1);


ALTER TABLE NashvilleHousing
Add PropertyCity Nvarchar(255);

update NashvilleHousing
set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress));



--- Break Owner Address 
SELECT *
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address
, PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City
, PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM NashvilleHousing




ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);



--- Change Y and N to Yes and No in 'Sold As Vacant' field
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)



--- Use CASE Statement to update Y to 'Yes' and N to 'No'
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
from NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END



--- Remove Duplicates using CTE's
WITH rowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, 
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID
) AS row_num
FROM NashvilleHousing
--order by ParcelID
--where row_num >1
)
SELECT *
FROM rowNumCTE
WHERE row_num =1
ORDER BY PropertyAddress



--- DELETE UNUSED COLUMNS
SELECT * 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN ownerAddress, TaxDistrict, PropertyAddress, SaleDate









