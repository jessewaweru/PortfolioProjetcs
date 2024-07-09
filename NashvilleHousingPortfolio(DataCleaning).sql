SELECT
	*
FROM
	Portfolio_Projects.dbo.NashvilleHousing

--  Populate Property Address Data
SELECT
	*
FROM
	Portfolio_Projects.dbo.NashvilleHousing
ORDER BY
	ParcelID
	--NOTE: PROPERTY ADDRESS MATCHES THE PARCELID SO IN THE CASE WHERE THE PROPERTY ADDRESS IS NULL, 
	--...I POPULATED IT WITH THE PARCELID AS MY REFERENCE
SELECT
	TB1.ParcelID,
	TB1.PropertyAddress,
	TB2.ParcelID,
	TB2.PropertyAddress,
	ISNULL(TB1.PropertyAddress,TB2.PropertyAddress)
FROM
	Portfolio_Projects.dbo.NashvilleHousing AS TB1
JOIN 
	Portfolio_Projects.dbo.NashvilleHousing AS TB2
	ON TB1.ParcelID = TB2.ParcelID
	AND TB1.UniqueID <> TB2.UniqueID
WHERE
	TB1.PropertyAddress IS NULL

UPDATE 
	TB1
SET
	PropertyAddress = ISNULL(TB1.PropertyAddress,TB2.PropertyAddress)
FROM
	Portfolio_Projects.dbo.NashvilleHousing AS TB1
JOIN 
	Portfolio_Projects.dbo.NashvilleHousing AS TB2
	ON TB1.ParcelID = TB2.ParcelID
	AND TB1.UniqueID <> TB2.UniqueID
WHERE
	TB1.PropertyAddress IS NULL
	-- I confirmed the property addresses field has been prefilled using the ISNULL statement
SELECT
	*
FROM
	Portfolio_Projects.dbo.NashvilleHousing

-- Breaking Down the Property Address field into Individual fields i.e. Address and City
SELECT
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM
	Portfolio_Projects.dbo.NashvilleHousing
	-- I then addedd the newly formed address and city into respective fields by using ALTER TABLE to introduce the new fields
	--and Updating the new fields using the UPDATE statement

ALTER TABLE Portfolio_Projects.dbo.NashvilleHousing
ADD PropertySplitAddress varchar(255);

UPDATE Portfolio_Projects.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Portfolio_Projects.dbo.NashvilleHousing
ADD PropertySplitCity varchar(255)

UPDATE Portfolio_Projects.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT
	*
FROM
	Portfolio_Projects.dbo.NashvilleHousing

-- Breaking Down the Property Address field into Individual fields i.e. Address, City, and State
SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM
	Portfolio_Projects.dbo.NashvilleHousing

ALTER TABLE Portfolio_Projects.dbo.NashvilleHousing
ADD OwnerSplitAddress varchar(255);

UPDATE Portfolio_Projects.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Portfolio_Projects.dbo.NashvilleHousing
ADD OwnerSplitCity varchar(255)

UPDATE Portfolio_Projects.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Portfolio_Projects.dbo.NashvilleHousing
ADD OwnerSplitState varchar(255)

UPDATE Portfolio_Projects.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in "Sold as Vacant" Field
SELECT
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
	END
FROM
	Portfolio_Projects.dbo.NashvilleHousing

UPDATE
	Portfolio_Projects.dbo.NashvilleHousing
SET
	SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
	END

--Remove Duplicates using CTE
WITH RemoveDup AS(
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) AS row_num
FROM
	Portfolio_Projects.dbo.NashvilleHousing
	--NOTE: I made the assumption that the duplicate rows would have the same mentioned fields in the partition by statements between them
	)
DELETE
FROM
	RemoveDup
WHERE
	row_num >1
	-- There were 104 duplicate rows
