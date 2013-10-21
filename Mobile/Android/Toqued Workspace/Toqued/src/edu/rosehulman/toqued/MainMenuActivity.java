package edu.rosehulman.toqued;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.Spinner;
import android.widget.Toast;

/*
 * Fridge and stove artwork from http://www.wesburke.com, under Creative Commons 3.0
 * Book from http://www.mcdodesign.com, free for non commercial use, no commercial use allowed
 * 
 * Features:
 * Fridge: Store items (name, quantity, unit) on a shelf on on the list.  Can add, edit, and delete these.  Can swap items between the two.  Data is persistent, and can be linked to recipes.
 * Stove: Search for recipes by meal, as well as select a meal at random.  Have the ability to filter by other criteria (such as prep time or ingredients or servings).
 * Recipe Book: Can add, edit, and delete recipes.  Can add steps to a recipe.  Have the functionality to add pictures, but that turns out to be fairly difficult.  
 */

public class MainMenuActivity extends Activity implements OnClickListener {
	
	public static final String TQD = "TQD";
	
	private ImageButton mFridgeButton;
	private ImageButton mStoveButton;
	private ImageButton mRecipeButton;
	
	private DatabaseBackend mDbAdapter;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_menu);

        //Find image buttons and set listeners
        mFridgeButton = (ImageButton) findViewById(R.id.fridge_image_button);
        mStoveButton = (ImageButton) findViewById(R.id.stove_image_button);
        mRecipeButton = (ImageButton) findViewById(R.id.recipe_image_button);
        
        mFridgeButton.setOnClickListener(this);
        mStoveButton.setOnClickListener(this);
        mRecipeButton.setOnClickListener(this);
        
        mDbAdapter = new DatabaseBackend(this);
        mDbAdapter.open();
    }
   
    
	@Override
	protected void onDestroy() {
		super.onDestroy();
		mDbAdapter.close();
	}

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_main_menu, menu);
        return true;
    }
    
    //Two menu items, about and help.  Launch dialogs for both.
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	switch (item.getItemId()) {
		case R.id.about_menu_option:
			Log.d(TQD, "Clicked about menu option");
			final Dialog aboutDialog = new Dialog(this);
			aboutDialog.setContentView(R.layout.activity_about_toqued);
			aboutDialog.setTitle(R.string.menu_about);
			Button aboutDoneButton = (Button) aboutDialog.findViewById(R.id.about_done_button);
			aboutDoneButton.setOnClickListener(new View.OnClickListener() {
				public void onClick(View v) {
					aboutDialog.dismiss();
				}
			});
			aboutDialog.show();
			return true;
		case R.id.help_menu_option:
			Log.d(TQD, "Clicked help menu option");
			final Dialog helpDialog = new Dialog(this);
			helpDialog.setContentView(R.layout.activity_help_toqued);
			helpDialog.setTitle(R.string.menu_help);
			Button helpDoneButton = (Button) helpDialog.findViewById(R.id.help_done_button);
			helpDoneButton.setOnClickListener(new View.OnClickListener() {
				public void onClick(View v) {
					helpDialog.dismiss();
				}
			});
			helpDialog.show();
			return true;
		}
		return false;
    }

    //Onclick specifies the behavior for each of the three main buttons on the screen
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.fridge_image_button:
			Log.d(TQD, "Launching fridge menu");
			//Launches the fridge intent
			Intent fridgeIntent = new Intent(this,FridgeMenuActivity.class);
			this.startActivity(fridgeIntent);
			//TODO: Add extras, if necessary
			break;
		case R.id.stove_image_button:
			Log.d(TQD, "Launching stove menu");
			//Launches the stove intent (which may turn into a dialog...)
			Intent stoveIntent = new Intent(this,StoveMenuActivity.class);
			this.startActivity(stoveIntent);
			//TODO: Add extras, if necessary
			break;
		case R.id.recipe_image_button:
			Log.d(TQD, "Launching recipe book menu");
			//Recipe book dialog launcher, which is pretty slick
			AlertDialog.Builder mealDialog = new AlertDialog.Builder(this);
			mealDialog.setTitle(R.string.recipe_selection);
			mealDialog.setItems(R.array.recipe_choice_array, new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
					Resources r = getResources();
					String[] choices = r.getStringArray(R.array.recipe_choice_array);
					switch (which) {
					case 0:	//Add
						Log.d(TQD, "Adding a recipe");
						final Dialog addRecipeDialog = new Dialog(MainMenuActivity.this);
						addRecipeDialog.setContentView(R.layout.add_recipe_dialog);
						addRecipeDialog.setTitle(R.string.add_a_recipe_dialog_title);
						Button startButton = (Button) addRecipeDialog.findViewById(R.id.recipe_add_dialog_start_button);
						Button cancelButton = (Button) addRecipeDialog.findViewById(R.id.recipe_add_dialog_cancel_button);
						final EditText name = (EditText) addRecipeDialog.findViewById(R.id.recipe_add_dialog_name_edit_text);
						final EditText prepTime = (EditText) addRecipeDialog.findViewById(R.id.recipe_add_dialog_prep_time_edit_text);
						final Spinner prepUnit = (Spinner) addRecipeDialog.findViewById(R.id.recipe_add_dialog_units_spinner);
						final EditText servings = (EditText) addRecipeDialog.findViewById(R.id.recipe_add_dialog_servings_edit_text);
						final Spinner type = (Spinner) addRecipeDialog.findViewById(R.id.recipe_add_dialog_type_spinner);
						
						//Create array adapter for the spinner
						ArrayAdapter<CharSequence> prepUnitSpinnerList = ArrayAdapter.createFromResource(MainMenuActivity.this, R.array.prep_time_units, android.R.layout.simple_spinner_item);
						prepUnitSpinnerList.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
						prepUnit.setAdapter(prepUnitSpinnerList);
						
						//Create array adapter for the spinner
						ArrayAdapter<CharSequence> recipeTypeList = ArrayAdapter.createFromResource(MainMenuActivity.this, R.array.meal_array, android.R.layout.simple_spinner_item);
						recipeTypeList.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
						type.setAdapter(recipeTypeList);
						
						startButton.setOnClickListener(new View.OnClickListener() {
							public void onClick(View v) {
								
								if(name.getText().toString().equals("")){
									Toast.makeText(MainMenuActivity.this, "Please input an item name", Toast.LENGTH_SHORT).show();
									addRecipeDialog.dismiss();
									return;
								}
								
								int pTime = 0;
								try{
									pTime = Integer.parseInt(prepTime.getText().toString());
								}catch(Exception NumberFormatException){
									try{
										pTime = (int) Double.parseDouble(prepTime.getText().toString());
									}catch(Exception DoubleFormatException){
										Log.d(MainMenuActivity.TQD, "number failure, bro");
										Toast.makeText(MainMenuActivity.this, "Please input a numeric quantity for prep time", Toast.LENGTH_SHORT).show();
										addRecipeDialog.dismiss();
										return;
									}
								}
								
								int changedServings = 0;
								try{
									changedServings = Integer.parseInt(servings.getText().toString());
								}catch(Exception NumberFormatException){
									try{
										changedServings = (int) Double.parseDouble(servings.getText().toString());
									}catch(Exception DoubleFormatException){
										Log.d(MainMenuActivity.TQD, "number failure, bro");
										Toast.makeText(MainMenuActivity.this, "Please input a numeric quantity for servings", Toast.LENGTH_SHORT).show();
										addRecipeDialog.dismiss();
										return;
									}
								}
								
								
								RecipeStructure temp = new RecipeStructure();
								temp.setRecipeName(name.getText().toString());
								temp.setPrepTime(pTime);
								temp.setPrepUnit(prepUnit.getItemAtPosition(prepUnit.getLastVisiblePosition()).toString());
								temp.setServings(changedServings);
								
								if(type.getItemAtPosition(type.getLastVisiblePosition()).toString().equals("Breakfast")){
									temp.setType(DatabaseBackend.RECIPE_TYPE.BREAKFAST);
								}else if(type.getItemAtPosition(type.getLastVisiblePosition()).toString().equals("Lunch")){
									temp.setType(DatabaseBackend.RECIPE_TYPE.LUNCH);
								}else if(type.getItemAtPosition(type.getLastVisiblePosition()).toString().equals("Dinner")){
									temp.setType(DatabaseBackend.RECIPE_TYPE.DINNER);
								}else if(type.getItemAtPosition(type.getLastVisiblePosition()).toString().equals("Dessert")){
									temp.setType(DatabaseBackend.RECIPE_TYPE.DESSERT);
								}else if(type.getItemAtPosition(type.getLastVisiblePosition()).toString().equals("Snack")){
									temp.setType(DatabaseBackend.RECIPE_TYPE.SNACK);
								}
								
								RecipeStructure returned = mDbAdapter.addRecipe(temp);
								Toast.makeText(MainMenuActivity.this, "Adding recipe: " + returned.getRecipeName(), Toast.LENGTH_SHORT).show();
								
								addRecipeDialog.dismiss();
								Intent addIntent = new Intent(MainMenuActivity.this, RecipeEditActivity.class);
								addIntent.putExtra(getString(R.string.key_recipe_id), returned.getId());
								MainMenuActivity.this.startActivity(addIntent);
							}
						});
						cancelButton.setOnClickListener(new View.OnClickListener() {
							public void onClick(View v) {
								addRecipeDialog.dismiss();
							}
						});
						addRecipeDialog.show();
						break;
					case 1:	//Edit
						Log.d(TQD, "Edit a recipe");
						//Launches the recipe list, which someone can then select to edit (will be delt with in that class)
						Intent editIntent = new Intent(MainMenuActivity.this, RecipeBookViewActivity.class);
						editIntent.putExtra(getString(R.string.KEY_MEAL_SELECTION), getString(R.string.edit));
						MainMenuActivity.this.startActivity(editIntent);
						break;
						
					case 2:	//Delete
						Log.d(TQD, "Delete a recipe");
						//Launches the recipe list, which someone can then delete a recipe from (will be delt with there)
						Intent deleteIntent = new Intent(MainMenuActivity.this, RecipeBookViewActivity.class);
						deleteIntent.putExtra(getString(R.string.KEY_MEAL_SELECTION), getString(R.string.delete));
						MainMenuActivity.this.startActivity(deleteIntent);
						break;
					}
					dialog.dismiss();
				}
			});
			mealDialog.setNeutralButton(R.string.cancel, new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
					dialog.dismiss();
				}
			});
			mealDialog.show();
			
			break;
		default:
			Log.d(TQD, "How did you get here?");
			break;
		}
		
	}
}
