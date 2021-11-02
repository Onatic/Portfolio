SELECT *
FROM Nashville

-- Changed Date format

ALTER TABLE Nashville
ADD SaleDateNew DATE;

Update Nashville
SET SaleDateNew = CONVERT(DATE,SaleDate)

SELECT SaleDateNew
FROM HousingData.dbo.Nashville

-- Populate Property Address data

SELECT *
FROM HousingData.dbo.Nashville
WHERE PropertyAddress is null
ORDER BY ParcelID

-- Populate Null values in propertyaddress with property address of same parcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingData.dbo.Nashville a
JOIN HousingData.dbo.Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingData.dbo.Nashville a
JOIN HousingData.dbo.Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


-- Split PropertyAddress into Address and City using substring

SELECT PropertyAddress
FROM HousingData.dbo.Nashville

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM HousingData.dbo.Nashville

ALTER TABLE Nashville
ADD PropertyAddressNew NVARCHAR(100),
	PropertyAddressCity NVARCHAR(100);

Update Nashville
SET PropertyAddressNew = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ),
	PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));



-- Split OwnerAddress into Address, City, and State using Parsename

SELECT OwnerAddress
FROM HousingData.dbo.Nashville

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM HousingData.dbo.Nashville

ALTER TABLE Nashville
ADD OwnerAddressNew NVARCHAR(100),
	OwnerAddressCity NVARCHAR(100),
	OwnerAddressState NVARCHAR(100);

UPDATE Nashville
SET OwnerAddressNew = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

SELECT *
FROM HousingData.dbo.Nashville


-- Replace Y and N to Yes and No 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingData.dbo.Nashville
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM HousingData.dbo.Nashville


Update Nashville
SET SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- Finding Duplicates using CTE

WITH RowNumCTE AS
(
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY parcelID) AS Dup_Num
FROM HousingData.dbo.Nashville
)


SELECT *
FROM RowNumCTE
WHERE Dup_Num > 1

-- Delete Duplicates
DELETE
FROM RowNumCTE
WHERE Dup_Num > 1


-- Delete Unused Columns


SELECT *
FROM HousingData.dbo.Nashville;

ALTER TABLE HousingData.dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
