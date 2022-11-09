SELECT *
FROM PortfolioProject..NashvilleHousing

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

-- Converting to date type

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing

-- Populating property adress

SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID

SELECT p1.ParcelID, p1.PropertyAddress, p2.ParcelID, p2.PropertyAddress
, ISNULL(p1.PropertyAddress, p2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing p1
JOIN PortfolioProject..NashvilleHousing p2
	ON p1.ParcelID = p2.ParcelID
	AND p1.[UniqueID ] <> p2.[UniqueID ]
WHERE p1.PropertyAddress is null

UPDATE p1
SET PropertyAddress = ISNULL(p1.PropertyAddress, p2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing p1
JOIN PortfolioProject..NashvilleHousing p2
	ON p1.ParcelID = p2.ParcelID
	AND p1.[UniqueID ] <> p2.[UniqueID ]
WHERE p1.PropertyAddress is null

-- Splitting property adress

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- Splitting owner address

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Setting Y and N to Yes and No

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'No' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- Remove Duplicates

WITH Dups AS (
SELECT *
, ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) as row_num
FROM PortfolioProject..NashvilleHousing)

DELETE
FROM Dups
WHERE row_num > 1

-- Delete Columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate

SELECT *
FROM PortfolioProject..NashvilleHousing
