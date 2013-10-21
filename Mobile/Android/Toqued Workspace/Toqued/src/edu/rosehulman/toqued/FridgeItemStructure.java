package edu.rosehulman.toqued;

public class FridgeItemStructure {
	
	private int mid;
	private String mItemName;
	private double mQuantity;
	private String mUnit;
	private DatabaseBackend.FRIDGE_LOCATIONS mLocation;
	
	public FridgeItemStructure() {
		mid = 0;
		mItemName = "";
		mQuantity = 0;
		mUnit = "";
		setLocation(DatabaseBackend.FRIDGE_LOCATIONS.SHELF);
	}
	
	public FridgeItemStructure(String name, double quantity, String unit, DatabaseBackend.FRIDGE_LOCATIONS location) {
		mItemName = name;
		mQuantity = quantity;
		mUnit = unit;
		mLocation = location;
	}
	
	public String getItemName() {
		return mItemName;
	}
	
	public void setItemName(String mItemName) {
		this.mItemName = mItemName;
	}
	
	public double getQuantity() {
		return mQuantity;
	}
	
	public void setQuantity(double mQuantity) {
		this.mQuantity = mQuantity;
	}
	
	public String getUnit() {
		return mUnit;
	}
	
	public void setUnit(String mUnit) {
		this.mUnit = mUnit;
	}
	
	@Override
	public String toString() {
		return mItemName + ", " + mQuantity + " " + mUnit;
	}
	
	@Override
	public boolean equals(Object o) {
		return (this.getItemName().equals(((FridgeItemStructure) o).getItemName()) &&
				this.getQuantity() == (((FridgeItemStructure) o).getQuantity()) &&
				this.getUnit().equals(((FridgeItemStructure) o).getUnit()));
	}

	public int getId() {
		return mid;
	}

	public void setId(int id) {
		this.mid = id;
	}

	public int getLocationInt() {
		return mLocation.ordinal();
	}
	
	public void setLocationInt(int location){
		this.mLocation = DatabaseBackend.FRIDGE_LOCATIONS.values()[location];
	}
	
	
	public DatabaseBackend.FRIDGE_LOCATIONS getLocation() {
		return this.mLocation;
	}
	
	public void setLocation(DatabaseBackend.FRIDGE_LOCATIONS mLocation) {
		this.mLocation = mLocation;
	}
	
}
