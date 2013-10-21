package edu.rosehulman.toqued;

import java.util.ArrayList;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteAbortException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class DatabaseBackend {
	
	private DatabaseBackendHelper mOpenHelper;
	private SQLiteDatabase mDb;
	
	public enum FRIDGE_LOCATIONS {SHELF, LIST};
	
	public enum RECIPE_TYPE {BREAKFAST, LUNCH, DINNER, DESSERT, SNACK};
	
	//boilerplate for the database itself
	private static final String DATABASE_NAME = "backend.db";
	private static final int DATABASE_VERSION = 9;
	
	//items table
	private static final String ITEMS_TABLE = "items";
	private static final String ITEMS_ID_KEY = "_id";
	private static final int ITEMS_ID_COLUMN = 0;
	private static final String ITEMS_NAME_KEY = "name";
	private static final int ITEMS_NAME_COLUMN = 1;
	private static final String ITEMS_QTY_KEY = "quantity";
	private static final int ITEMS_QTY_COLUMN = 2;
	private static final String ITEMS_UNIT_KEY = "unit";
	private static final int ITEMS_UNIT_COLUMN = 3;
	private static final String ITEMS_LOCATION_KEY = "location";
	private static final int ITEMS_LOCATION_COLUMN = 4;
	
	//recipes table
	private static final String RECIPES_TABLE = "recipes";
	private static final String RECIPES_ID_KEY = "_id";
	private static final int RECIPES_ID_COLUMN = 0;
	private static final String RECIPES_NAME_KEY = "name";
	private static final int RECIPES_NAME_COLUMN = 1;
	private static final String RECIPES_PREP_KEY = "prep_time";
	private static final int RECIPES_PREP_COLUMN = 2;
	private static final String RECIPES_PREP_UNIT_KEY = "prep_unit";
	private static final int RECIPES_PREP_UNIT_COLUMN = 3;
	private static final String RECIPES_SERVINGS_KEY = "servings";
	private static final int RECIPES_SERVINGS_COLUMN = 4;
	private static final String RECIPES_TYPE_KEY = "type";
	private static final int RECIPES_TYPE_COLUMN = 5;
	
	//steps table
	private static final String STEPS_TABLE = "steps";
	private static final String STEPS_ID_KEY = "_id";
	private static final int STEPS_ID_COLUMN = 0;
	private static final String STEPS_RECIPE_ID_KEY = "recipe_id";
	private static final int STEPS_RECIPE_ID_COLUMN = 1;
	private static final String STEPS_STEP_NUMBER_KEY = "step_number";
	private static final int STEPS_STEP_NUMBER_COLUMN = 2;
	private static final String STEPS_INSTRUCTION_KEY = "instruction";
	private static final int STEPS_INSTRUCTION_COLUMN = 3;
	
	//recipe has ingredients table
	private static final String HAS_INGREDIENTS_TABLE = "recipeHasIngredients";
	private static final String HAS_INGREDIENTS_ID_KEY = "_id";
	private static final int HAS_INGREDIENTS_ID_COLUMN = 0;
	private static final String HAS_INGREDIENTS_R_ID_KEY = "recipe_id";
	private static final int HAS_INGREDIENTS_R_ID_COLUMN = 1;
	private static final String HAS_INGREDIENTS_I_ID_KEY = "ingredient_id";
	private static final int HAS_INGREDIENTS_I_ID_COLUMN = 2;
	
	public DatabaseBackend(Context c){
		mOpenHelper = new DatabaseBackendHelper(c);
	}
	
	public void open() throws SQLiteAbortException{
		mDb = mOpenHelper.getWritableDatabase();
	}
	
	public void close(){
		mDb.close();
	}
	
	private ContentValues getContentValuesFromItem(FridgeItemStructure item){
		ContentValues rowValues = new ContentValues();
		rowValues.put(ITEMS_NAME_KEY, item.getItemName());
		rowValues.put(ITEMS_QTY_KEY, item.getQuantity());
		rowValues.put(ITEMS_UNIT_KEY, item.getUnit());
		rowValues.put(ITEMS_LOCATION_KEY, item.getLocationInt());
		return rowValues;
	}
	
	public FridgeItemStructure getItemFromCursor(Cursor c){
		FridgeItemStructure item = new FridgeItemStructure();
		item.setId(c.getInt(ITEMS_ID_COLUMN));
		item.setItemName(c.getString(ITEMS_NAME_COLUMN));
		item.setQuantity(c.getInt(ITEMS_QTY_COLUMN));
		item.setUnit(c.getString(ITEMS_UNIT_COLUMN));
		item.setLocationInt(c.getInt(ITEMS_LOCATION_COLUMN));
		return item;
	}
	
	public FridgeItemStructure addItem(FridgeItemStructure item){
		ContentValues rowValues = getContentValuesFromItem(item);
		mDb.insert(ITEMS_TABLE, null, rowValues);
		
		Cursor c = mDb.query(ITEMS_TABLE,  new String[] {ITEMS_ID_KEY, ITEMS_NAME_KEY, ITEMS_QTY_KEY, ITEMS_UNIT_KEY, ITEMS_LOCATION_KEY},  null,  null,  null,  null,  null );
		
//		c.moveToFirst();
		c.moveToLast();
		return getItemFromCursor(c);
	}
	
	public Cursor getItemsCursor(FRIDGE_LOCATIONS location){
		return mDb.query(ITEMS_TABLE, new String[]{ITEMS_ID_KEY, ITEMS_NAME_KEY, ITEMS_QTY_KEY, ITEMS_UNIT_KEY, ITEMS_LOCATION_KEY}, ITEMS_LOCATION_KEY + " = ?", new String[]{location.ordinal() + ""}, null, null, null);
	}
	
	public void deleteItem(FridgeItemStructure item){
		mDb.delete(ITEMS_TABLE, ITEMS_ID_KEY + " = ?", new String[] {Integer.toString(item.getId())});
	}
	
	public void updateItem(FridgeItemStructure item) {
		ContentValues rowValues = getContentValuesFromItem(item);

		String whereClause = ITEMS_ID_KEY + "=" + item.getId();
		mDb.update(ITEMS_TABLE, rowValues, whereClause, null);
	}
	
	private ContentValues getContentValuesFromRecipe(RecipeStructure recipe){
		ContentValues rowValues = new ContentValues();
		rowValues.put(RECIPES_NAME_KEY, recipe.getRecipeName());
		rowValues.put(RECIPES_PREP_KEY, recipe.getPrepTime());
		rowValues.put(RECIPES_PREP_UNIT_KEY, recipe.getPrepUnit());
		rowValues.put(RECIPES_SERVINGS_KEY, recipe.getServings());
		rowValues.put(RECIPES_TYPE_KEY, recipe.getTypeInt());
		return rowValues;
	}
	
	public RecipeStructure getRecipeFromCursor(Cursor c){
		RecipeStructure recipe = new RecipeStructure();
		recipe.setId(c.getInt(RECIPES_ID_COLUMN));
		recipe.setRecipeName(c.getString(RECIPES_NAME_COLUMN));
		recipe.setPrepTime(c.getInt(RECIPES_PREP_COLUMN));
		recipe.setPrepUnit(c.getString(RECIPES_PREP_UNIT_COLUMN));
		recipe.setServings(c.getInt(RECIPES_SERVINGS_COLUMN));
		recipe.setTypeInt(c.getInt(RECIPES_TYPE_COLUMN));
		return recipe;
	}
	
	public RecipeStructure addRecipe(RecipeStructure recipe){
		ContentValues rowValues = getContentValuesFromRecipe(recipe);
		mDb.insert(RECIPES_TABLE, null, rowValues);
		
		Cursor c = mDb.query(RECIPES_TABLE,  new String[] {RECIPES_ID_KEY, RECIPES_NAME_KEY, RECIPES_PREP_KEY, RECIPES_PREP_UNIT_KEY, RECIPES_SERVINGS_KEY, RECIPES_TYPE_KEY},  null,  null,  null,  null,  null);
		
//		c.moveToFirst();
		c.moveToLast();
		return getRecipeFromCursor(c);
	}
	
	public RecipeStructure getRecipeById(int id){
		Cursor c = mDb.query(RECIPES_TABLE, new String[] {RECIPES_ID_KEY, RECIPES_NAME_KEY, RECIPES_PREP_KEY, RECIPES_PREP_UNIT_KEY, RECIPES_SERVINGS_KEY, RECIPES_TYPE_KEY}, RECIPES_ID_KEY + " = ?", new String[]{id + ""}, null, null, null, "1");
		c.moveToFirst();
		return getRecipeFromCursor(c);
	}
	
	public Cursor getRecipesCursor(RECIPE_TYPE type){
		return mDb.query(RECIPES_TABLE, new String[]{RECIPES_ID_KEY, RECIPES_NAME_KEY, RECIPES_PREP_KEY, RECIPES_PREP_UNIT_KEY, RECIPES_SERVINGS_KEY, RECIPES_TYPE_KEY}, RECIPES_TYPE_KEY + " = ?", new String[]{type.ordinal() + ""}, null, null, null);
	}
	
	public Cursor getRecipeIds(){
		return mDb.query(RECIPES_TABLE, new String[] {RECIPES_ID_KEY}, null, null , null, null, null);
	}
	
	public Cursor getAllRecipesCursor(){
		return mDb.query(RECIPES_TABLE, new String[]{RECIPES_ID_KEY, RECIPES_NAME_KEY, RECIPES_PREP_KEY, RECIPES_PREP_UNIT_KEY, RECIPES_SERVINGS_KEY, RECIPES_TYPE_KEY}, null, null, null, null, null);
	}
	
	public void deleteRecipe(RecipeStructure recipe){
		mDb.delete(RECIPES_TABLE, RECIPES_ID_KEY + " = ?", new String[] {Integer.toString(recipe.getId())});
	}
	
	public void updateRecipe(RecipeStructure recipe) {
		ContentValues rowValues = getContentValuesFromRecipe(recipe);

		String whereClause = RECIPES_ID_KEY + "=" + recipe.getId();
		mDb.update(RECIPES_TABLE, rowValues, whereClause, null);
	}
	
	private ContentValues getContentValuesFromStep(RecipeStep step){
		ContentValues rowValues = new ContentValues();
		rowValues.put(STEPS_RECIPE_ID_KEY, step.getRecipeId());
		rowValues.put(STEPS_STEP_NUMBER_KEY, step.getStepNumber());
		rowValues.put(STEPS_INSTRUCTION_KEY, step.getInstructions());
		return rowValues;
	}
	
	public RecipeStep getStepFromCursor(Cursor c){
		RecipeStep step = new RecipeStep();
		step.setId(c.getInt(STEPS_ID_COLUMN));
		step.setRecipeId(c.getInt(STEPS_RECIPE_ID_COLUMN));
		step.setStepNumber(c.getInt(STEPS_STEP_NUMBER_COLUMN));
		step.setInstructions(c.getString(STEPS_INSTRUCTION_COLUMN));
		return step;
	}
	
	public RecipeStep addStep(RecipeStep step){
		ContentValues rowValues = getContentValuesFromStep(step);
		mDb.insert(STEPS_TABLE, null, rowValues);
		
		Cursor c = mDb.query(STEPS_TABLE,  new String[] {STEPS_ID_KEY, STEPS_RECIPE_ID_KEY, STEPS_STEP_NUMBER_KEY, STEPS_INSTRUCTION_KEY},  null,  null,  null,  null,  null);
		
//		c.moveToFirst();
		c.moveToLast();
		return getStepFromCursor(c);
	}
	
	public ArrayList<RecipeStep> getStepsByRecipeId(int id){
		ArrayList<RecipeStep> steps = new ArrayList<RecipeStep>();
		
		Cursor c = mDb.query(STEPS_TABLE, new String[] {STEPS_ID_KEY, STEPS_RECIPE_ID_KEY, STEPS_STEP_NUMBER_KEY, STEPS_INSTRUCTION_KEY}, STEPS_RECIPE_ID_KEY + " = ?", new String[]{id + ""}, null, null, null);
		c.moveToFirst();
		
		while(c.moveToNext()){
			steps.add(getStepFromCursor(c));
		}
		return steps;
	}
	
	public Cursor getStepsCursor(){
		return mDb.query(STEPS_TABLE, new String[]{STEPS_ID_KEY, STEPS_RECIPE_ID_KEY, STEPS_STEP_NUMBER_KEY, STEPS_INSTRUCTION_KEY}, null, null, null, null, null);
	}
	
	
	public void deleteStep(RecipeStep step){
		mDb.delete(STEPS_TABLE, STEPS_ID_KEY + " = ?", new String[] {Integer.toString(step.getId())});
	}
	
	public void updateStep(RecipeStep step) {
		ContentValues rowValues = getContentValuesFromStep(step);

		String whereClause = STEPS_ID_KEY + "=" + step.getId();
		mDb.update(STEPS_TABLE, rowValues, whereClause, null);
	}
	
	
	
	public FridgeItemStructure addHasItem(int id, FridgeItemStructure item){
		ContentValues rowValues = new ContentValues();
		rowValues.put(HAS_INGREDIENTS_R_ID_KEY, id);
		rowValues.put(HAS_INGREDIENTS_I_ID_KEY, item.getId());
		mDb.insert(ITEMS_TABLE, null, rowValues);
		
		Cursor c = mDb.query(HAS_INGREDIENTS_TABLE,  new String[] {HAS_INGREDIENTS_ID_KEY, HAS_INGREDIENTS_R_ID_KEY, HAS_INGREDIENTS_I_ID_KEY},  null,  null,  null,  null,  null );
		
//		c.moveToFirst();
		c.moveToLast();
		return getItemFromCursor(c);
	}
	
	public Cursor getHasItemsCursor(){
		return mDb.query(HAS_INGREDIENTS_TABLE, new String[]{HAS_INGREDIENTS_ID_KEY, HAS_INGREDIENTS_R_ID_KEY, HAS_INGREDIENTS_I_ID_KEY}, null, null, null, null, null);
	}
	
	public Cursor getSingleItemsCursor(int rId){
		return mDb.query(HAS_INGREDIENTS_TABLE, new String[]{HAS_INGREDIENTS_I_ID_KEY}, HAS_INGREDIENTS_R_ID_KEY + " = ?", new String[]{rId + ""}, null, null, null);
	}
	
	public ArrayList<FridgeItemStructure> currentItemsForId(int id){
		ArrayList<FridgeItemStructure> temp = new ArrayList<FridgeItemStructure>();
		Cursor c = getSingleItemsCursor(id);
		c.moveToFirst();
		
		while(c.moveToNext()){
			temp.add(getItemFromCursor(c));
		}
		return temp;
	}
	
	public void deleteHasItem(FridgeItemStructure item){
		mDb.delete(HAS_INGREDIENTS_TABLE, HAS_INGREDIENTS_I_ID_KEY + " = ?", new String[] {Integer.toString(item.getId())});
	}
	
	public void updateHasItem(FridgeItemStructure item) {
		ContentValues rowValues = getContentValuesFromItem(item);

		String whereClause = HAS_INGREDIENTS_I_ID_KEY + "=" + item.getId();
		mDb.update(HAS_INGREDIENTS_TABLE, rowValues, whereClause, null);
	}
	
	private static class DatabaseBackendHelper extends SQLiteOpenHelper{
		
		private static String CREATE_STATEMENT_ITEMS;
		static{
			StringBuilder s = new StringBuilder();
			s.append("CREATE TABLE ");
			s.append(ITEMS_TABLE);
			s.append(" (");
			s.append(ITEMS_ID_KEY);
			s.append(" INTEGER PRIMARY KEY AUTOINCREMENT, ");
			s.append(ITEMS_NAME_KEY);
			s.append(" TEXT, ");
			s.append(ITEMS_QTY_KEY);
			s.append(" INTEGER, ");
			s.append(ITEMS_UNIT_KEY);
			s.append(" TEXT, ");
			s.append(ITEMS_LOCATION_KEY);
			s.append(" INTEGER)");
//			s.append("FOREIGN KEY() REFERENCES TABLE(),");
			CREATE_STATEMENT_ITEMS = s.toString();
		}
		private static String DROP_STATEMENT_ITEMS = "DROP TABLE IF EXISTS " + ITEMS_TABLE;
		
		private static String CREATE_STATEMENT_RECIPES;
		static{
			StringBuilder s = new StringBuilder();
			s.append("CREATE TABLE ");
			s.append(RECIPES_TABLE);
			s.append(" (");
			s.append(RECIPES_ID_KEY);
			s.append(" INTEGER PRIMARY KEY AUTOINCREMENT, ");
			s.append(RECIPES_NAME_KEY);
			s.append(" TEXT, ");
			s.append(RECIPES_PREP_KEY);
			s.append(" INTEGER, ");
			s.append(RECIPES_PREP_UNIT_KEY);
			s.append(" TEXT, ");
			s.append(RECIPES_SERVINGS_KEY);
			s.append(" INTEGER, ");
			s.append(RECIPES_TYPE_KEY);
			s.append(" INTEGER)");
//			s.append("FOREIGN KEY() REFERENCES TABLE(),");
			CREATE_STATEMENT_RECIPES = s.toString();
		}
		private static String DROP_STATEMENT_RECIPES = "DROP TABLE IF EXISTS " + RECIPES_TABLE;
		
		private static String CREATE_STATEMENT_STEPS;
		static{
			StringBuilder s = new StringBuilder();
			s.append("CREATE TABLE ");
			s.append(STEPS_TABLE);
			s.append(" (");
			s.append(STEPS_ID_KEY);
			s.append(" INTEGER PRIMARY KEY AUTOINCREMENT, ");
			s.append(STEPS_RECIPE_ID_KEY);
			s.append(" INTEGER, ");
			s.append(STEPS_STEP_NUMBER_KEY);
			s.append(" INTEGER, ");
			s.append(STEPS_INSTRUCTION_KEY);
			s.append(" TEXT)");
//			s.append("FOREIGN KEY() REFERENCES TABLE(),");
			CREATE_STATEMENT_STEPS = s.toString();
		}
		private static String DROP_STATEMENT_STEPS = "DROP TABLE IF EXISTS " + STEPS_TABLE;

		public DatabaseBackendHelper(Context context) {
			super(context, DATABASE_NAME, null, DATABASE_VERSION);
		}

		@Override
		public void onCreate(SQLiteDatabase db) {
			db.execSQL(CREATE_STATEMENT_ITEMS);
			db.execSQL(CREATE_STATEMENT_RECIPES);
			db.execSQL(CREATE_STATEMENT_STEPS);
		}

		@Override
		public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
			db.execSQL(DROP_STATEMENT_ITEMS);
			db.execSQL(DROP_STATEMENT_RECIPES);
			db.execSQL(DROP_STATEMENT_STEPS);
			onCreate(db);
			
		}
	
	}
}
