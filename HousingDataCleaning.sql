/*

Cleaning Data in SQL Queries 

*/

-- Changing name of uniqueID column, there was an import error that changed the name
ALTER TABLE nashvillehousing
RENAME COLUMN ï»¿UniqueID TO UniqueID; 


SELECT * 
FROM nashvillehousing;

-- Standardize Date Format

SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d,%Y')
FROM nashvillehousing;

UPDATE nashvillehousing SET SaleDate = STR_TO_DATE(SaleDate, '%M %d,%Y');


-- Populate Property Address data

-- Property Addresses are showing blank instead of null 

UPDATE nashvillehousing SET PropertyAddress = NULL WHERE PropertyAddress = '';


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashvillehousing AS a
JOIN nashvillehousing AS b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


-- Below is me trying out an update code but it didnt work 
/*UPDATE nashvillehousing
SET PropertyAddress = (SELECT IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashvillehousing AS a
JOIN nashvillehousing AS b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL);*/

UPDATE nashvillehousing t1,
     nashvillehousing t2 
 SET t2.propertyaddress = t1.propertyaddress
 WHERE t2.propertyaddress IS NULL
	AND t2.parcelid = t1.parcelid
	AND t1.propertyaddress is not null;

-- Breaking out Address into Individual Columns(Address,City,State)

SELECT PropertyAddress
FROM nashvillehousing
;

SELECT SUBSTRING_INDEX(PropertyAddress, ',', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX(PropertyAddress, ',', 2), ',', -1)
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD PropertySplitAddress varchar(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE nashvillehousing
ADD PropertySplitCity varchar(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(PropertyAddress, ',', 2), ',', -1);

SELECT OwnerAddress, SUBSTRING_INDEX(OwnerAddress, ',', -1)
FROM nashvillehousing
;

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress varchar(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashvillehousing
ADD OwnerSplitCity varchar(255);

UPDATE nashvillehousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE nashvillehousing
ADD OwnerSplitState varchar(255);

UPDATE nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',',-1);

-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT SoldAsVacant, COUNT(soldasvacant)
FROM nashvillehousing
GROUP BY SoldAsVacant;


SELECT SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM nashvillehousing;

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END;

-- Remove Duplicates

WITH RowNumCTE AS( 
SELECT *,
	row_number() OVER(
    PARTITION BY ParcelID, 
    PropertyAddress, 
    SalePrice, 
    SaleDate, 
    LegalReference
    ORDER BY UniqueID) AS row_num
FROM nashvillehousing
ORDER BY ParcelID
)
DELETE 
FROM nashvillehousing
USING nashvillehousing
JOIN RowNumCTE 
	ON nashvillehousing.UniqueID = RowNumCTE.UniqueID
WHERE row_num > 1;


-- Delete Unused Columns

SELECT *
FROM nashvillehousing;


ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;


