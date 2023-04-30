

-- Cleaning Data in SQL Queries

select * 
from PortfolioProject..NashvilleHousing

------------------------------------------------------------------
--Standardise Date Format

Select SaleDate, CONVERT (date,SaleDate) as SaleDateConverted
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing 
add SaleDateConverted Date

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT (date,SaleDate) 

--Populate Property Address data

SELECT A.ParcelID,A.PropertyAddress, B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
from PortfolioProject..NashvilleHousing as A
     join PortfolioProject..NashvilleHousing as B 
	 on A.ParcelID=B.ParcelID
	 and A.[UniqueID] <> B.[UniqueID]
Where A.PropertyAddress is null

UPDATE A
SET PropertyAddress= ISNULL(A.PropertyAddress,B.PropertyAddress)
from PortfolioProject..NashvilleHousing as A
     join PortfolioProject..NashvilleHousing as B 
	 on A.ParcelID=B.ParcelID
	 and A.[UniqueID] <> B.[UniqueID]
Where A.PropertyAddress is null

--Select PropertyAddress
--from PortfolioProject..NashvilleHousing
--where PropertyAddress is null

-------------------------------------------------------------------------------------------------------------
--Breaking out Address into individual columns (Address,City, State)

Select 
SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing 
add PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing 
SET PropertySplitAddress =  SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


Alter Table NashvilleHousing 
add PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing 
SET  PropertySplitCity= SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 
 
--- Breaking out Address into individual columns (Address,City, State) Exp : OwnerAddress using PARSENAME---------

select 
PARSENAME(REPLACE(owneraddress,',','.'),3) as OwnerSplitAddress,
PARSENAME(REPLACE(owneraddress,',','.'),2)as OwnerSplitCity,
PARSENAME(REPLACE(owneraddress,',','.'),1) as OwnerSplitState
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing 
add OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing 
SET OwnerSplitAddress =  PARSENAME(REPLACE(owneraddress,',','.'),3)

Alter Table NashvilleHousing 
add OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing 
SET OwnerSplitCity =  PARSENAME(REPLACE(owneraddress,',','.'),2)

Alter Table NashvilleHousing 
add OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress,',','.'),1) 


--Change Y and N to Yes and No in ''Solde as Vacant'' field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
case when SoldAsVacant ='n' then 'NO'
	 when SoldAsVacant ='y' then 'yes'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
set SoldAsVacant=
case when SoldAsVacant ='n' then 'NO'
	 when SoldAsVacant ='y' then 'yes'
	 else SoldAsVacant
	 end

--Remove Duplicates 

With RowNumCTE as (

SELECT * , 
Row_Number()  over (
PARTITION BY ParcelID,
			 propertyAddress,
			 salePrice,
			 SaleDate,
			 LegalReference
		order by UniqueID) as RowNum 


from PortfolioProject.dbo.NashvilleHousing
)
/* Select * */
DELETE  
from RowNumCTE
where RowNumCTE.RowNum <> 1

-------------------------------------------------------------------------------------

----Delete Unused Columns

select *  
from  PortfolioProject.dbo.NashvilleHousing

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate