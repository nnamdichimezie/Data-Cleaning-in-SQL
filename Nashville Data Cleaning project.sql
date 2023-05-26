/*
Cleaning Data in SQL Queries
*/

select * from Nashvillehousing

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From Nashvillehousing

-- Add a new column 'SaleDateOnly' with the Date data type

ALTER TABLE NashvilleHousing
ADD Date_Sales Date;

-- Update the new column with the date-only values
UPDATE NashvilleHousing
SET Date_Sales = CONVERT(Date, SaleDate);

-- Populate Property Address data

select * from Nashvillehousing
--where PropertyAddress is null
order by ParcelID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from Nashvillehousing as a
join Nashvillehousing as b
on a.ParcelID= b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress= isnull(a.PropertyAddress, b.PropertyAddress)
from Nashvillehousing as a
join Nashvillehousing as b
on a.ParcelID= b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from Nashvillehousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress)) as Address
from Nashvillehousing

ALTER TABLE NashvilleHousing
Add Address Nvarchar(255);

Update NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add City Nvarchar(255);

Update NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--select owner address

select OwnerAddress
from Nashvillehousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from Nashvillehousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(soldasvacant)
from Nashvillehousing
group by soldasvacant

select SoldAsVacant,
case when SoldAsVacant='N' then 'No'
when soldasvacant = 'Y' then 'Yes'
else SoldAsVacant
end
from Nashvillehousing

update Nashvillehousing
set SoldAsVacant= case when SoldAsVacant='N' then 'No'
when soldasvacant = 'Y' then 'Yes'
else SoldAsVacant
end


-- Remove Duplicates

WITH RowNumberCTE AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID,
								PropertyAddress,
				                SalePrice,
				                SaleDate,
				                LegalReference
								
ORDER BY UniqueID) AS RowNumber
FROM Nashvillehousing)

delete FROM RowNumberCTE WHERE RowNumber > 1;


-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
