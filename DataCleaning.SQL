  -----------------------------------------------------------Standardize Date Format
 Select *
From Project.dbo.NashVilleHousing

Select SaleDateConverted, CONVERT(Date,SaleDate)
From Project.dbo.NashVilleHousing

Update NashVilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashVilleHousing
Add SaleDateConverted Date; 

Update NashVilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-------------------------------------------------------------Populate Property Address Data

Select*
From Project.dbo.NashVilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Project.dbo.NashVilleHousing a
JOIN Project.dbo.NashVilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Project.dbo.NashVilleHousing a
JOIN Project.dbo.NashVilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

------------------------------------------------------Breaking out Address into individual columns (Address, City, State)

Select PropertyAddress
From Project.dbo.NashVilleHousing

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1 ,LEN(PropertyAddress)) as Address
From Project.dbo.NashVilleHousing

ALTER TABLE NashVilleHousing
Add PropertySplitAddress Nvarchar(255); 

Update NashVilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1)

ALTER TABLE NashVilleHousing
Add PropertySplitCity Nvarchar(255); 

Update NashVilleHousing
SET PropertySplitCity    = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1 ,LEN(PropertyAddress))

Select*
From Project.dbo.NashVilleHousing

Select OwnerAddress
From Project.dbo.NashVilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From Project.dbo.NashVilleHousing

ALTER TABLE NashVilleHousing
Add OwnerSplitAddress Nvarchar(255); 

Update NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashVilleHousing
Add OwnerSplitCity Nvarchar(255); 
Update NashVilleHousing
SET OwnerSplitCity    = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashVilleHousing
Add OwnerSplitState Nvarchar(255); 
Update NashVilleHousing
SET OwnerSplitState    = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select*
From Project.dbo.NashVilleHousing


-----------------------------------------------------------------------Change Y and N to YES and NO in "Sold as Vacant Field"

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From Project.dbo.NashVilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
From Project.dbo.NashVilleHousing


Update NashVilleHousing
SET SoldAsVacant=CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END

-----------------------------------------------------------------------------REMOVE DUPLICATES
WITH RowNumCTE	AS (
Select * ,
ROW_NUMBER () OVER (
PARTITION BY ParcelID,
            PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
			   UniqueID
			   ) row_num

From Project.dbo.NashVilleHousing
--Order by ParcelID
)
Select*
From RowNumCTE
Where row_num>1
Order by PropertyAddress



Select*
From Project.dbo.NashVilleHousing





----------------------------------------------------------------------------------DELETE UNUSED COLUMNS

Select*
From Project.dbo.NashVilleHousing

ALTER TABLE Project.dbo.NashVilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Project.dbo.NashVilleHousing
DROP COLUMN SaleDate
