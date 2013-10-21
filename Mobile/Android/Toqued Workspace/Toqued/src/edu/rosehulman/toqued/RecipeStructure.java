package edu.rosehulman.toqued;

public class RecipeStructure {
	
	private int mId;
	private String mRecipeName;
	private int mPrepTime;
	private String mPrepUnit;
	private int mServings;
	private DatabaseBackend.RECIPE_TYPE mType;


	public RecipeStructure(){
		mId = 0;
		mRecipeName = "";
		mPrepTime = 0;
		mPrepUnit = "";
		mServings = 0;
		setType(DatabaseBackend.RECIPE_TYPE.BREAKFAST);
	}
	
	public RecipeStructure(int id, String name, int prepTime, String prepUnit, int servings){
		mId = id;
		mRecipeName = name;
		mPrepTime = prepTime;
		mPrepUnit = prepUnit;
		mServings = servings;
	}
	
	public RecipeStructure(int id, String name, int prepTime, String prepUnit, int servings, DatabaseBackend.RECIPE_TYPE type){
		mId = id;
		mRecipeName = name;
		mPrepTime = prepTime;
		mPrepUnit = prepUnit;
		mServings = servings;
		mType = type;
	}
	
	public void setId(int mId) {
		this.mId = mId;
	}

	public void setRecipeName(String mRecipeName) {
		this.mRecipeName = mRecipeName;
	}

	public void setPrepTime(int mPrepTime) {
		this.mPrepTime = mPrepTime;
	}

	public void setPrepUnit(String mPrepUnit) {
		this.mPrepUnit = mPrepUnit;
	}

	public void setServings(int mServings) {
		this.mServings = mServings;
	}

	public int getId(){
		return mId;
	}
	
	public String getRecipeName() {
		return mRecipeName;
	}

	public int getPrepTime() {
		return mPrepTime;
	}
	
	public String getPrepUnit(){
		return mPrepUnit;
	}

	public int getServings() {
		return mServings;
	}
	
	@Override
	public boolean equals(Object o) {
		return this.getId() == ((RecipeStructure) o).getId();
	}

	public DatabaseBackend.RECIPE_TYPE getType() {
		return mType;
	}

	public void setType(DatabaseBackend.RECIPE_TYPE mType) {
		this.mType = mType;
	}
	
	public int getTypeInt() {
		return mType.ordinal();
	}

	public void setTypeInt(int location) {
		this.mType = DatabaseBackend.RECIPE_TYPE.values()[location];
	}

}
