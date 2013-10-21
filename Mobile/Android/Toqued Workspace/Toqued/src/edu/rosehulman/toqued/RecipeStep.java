package edu.rosehulman.toqued;

public class RecipeStep {

	private int mId;
	private int mRecipeId;
	private int mStepNumber;
	private String mIngredients;
	private String mInstructions;
	
	public RecipeStep(){
		mId = 0;
		mRecipeId = 0;
		mStepNumber = 0;
		mIngredients = "";
		mInstructions = "";
	}
	
	public RecipeStep(int recipeId, int step, String instructions){
		mRecipeId = recipeId;
		mStepNumber = step;
		mIngredients = "";
		mInstructions = instructions;
	}

	public RecipeStep(int recipeId, int step, String ingredients, String instructions){
		mRecipeId = recipeId;
		mStepNumber = step;
		mIngredients = ingredients;
		mInstructions = instructions;
	}
	
	public RecipeStep(int id, int recipeId, int step, String ingredients, String instructions){
		mId = id;
		mRecipeId = recipeId;
		mStepNumber = step;
		mIngredients = ingredients;
		mInstructions = instructions;
	}
	
	public int getStepNumber() {
		return mStepNumber;
	}

	public void setStepNumber(int mStepNumber) {
		this.mStepNumber = mStepNumber;
	}

	public String getIngredients() {
		return mIngredients;
	}

	public void setIngredients(String mIngredients) {
		this.mIngredients = mIngredients;
	}

	public String getInstructions() {
		return mInstructions;
	}

	public void setInstructions(String mInstructions) {
		this.mInstructions = mInstructions;
	}

	public int getRecipeId() {
		return mRecipeId;
	}

	public void setRecipeId(int mRecipeId) {
		this.mRecipeId = mRecipeId;
	}

	public int getId() {
		return mId;
	}

	public void setId(int mId) {
		this.mId = mId;
	}
}
