/*

Cleaning Data in SQL Queries

*/

use PortfolioProject

SELECT * FROM [dbo].[NashvilleHousing]


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM [dbo].[NashvilleHousing]


Update [dbo].[NashvilleHousing] Set SaleDate  =  CONVERT(date, SaleDate)

ALTER TABLE [dbo].[NashvilleHousing] ADD SaleDateConverted Date;

Update [dbo].[NashvilleHousing] Set SaleDateConverted  =  CONVERT(date, SaleDate)

SELECT SaleDateConverted
FROM [dbo].[NashvilleHousing]

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM [dbo].[NashvilleHousing]
WHERE PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)



SELECT PropertyAddress FROM [dbo].[NashvilleHousing]

SELECT PropertyAddress
,SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM [dbo].[NashvilleHousing]



ALTER TABLE [dbo].[NashvilleHousing] ADD PropertySPlitAddress Nvarchar(255);

SELECT PropertySPlitAddress FROM NashvilleHousing;

UPDATE NashvilleHousing 
SET PropertySPlitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE [dbo].[NashvilleHousing] ADD PropertySPlitCity Nvarchar(255);

SELECT PropertySPlitCity FROM NashvilleHousing;

UPDATE NashvilleHousing 
SET PropertySPlitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))






SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing




ALTER TABLE [dbo].[NashvilleHousing] ADD OwnerSPlitAddress Nvarchar(255);

SELECT OwnerSPlitAddress FROM NashvilleHousing;

UPDATE NashvilleHousing 
SET OwnerSPlitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE [dbo].[NashvilleHousing] ADD OwnerSPlitCity Nvarchar(255);

SELECT OwnerSPlitCity FROM NashvilleHousing;

UPDATE NashvilleHousing 
SET OwnerSPlitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE [dbo].[NashvilleHousing] ADD OwnerSPlitState Nvarchar(255);

SELECT OwnerSPlitState FROM NashvilleHousing;

UPDATE NashvilleHousing 
SET OwnerSPlitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field



SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From [dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [dbo].[NashvilleHousing]

Update NashvilleHousing
SET SoldAsVacant  = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
With RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) row_num
FROM [dbo].[NashvilleHousing]
--ORDER BY ParcelID
)
DELETE FROM RowNumCTE
Where row_num > 1 
--Order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
SELECT * FROM [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress´, SaleDate








-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















