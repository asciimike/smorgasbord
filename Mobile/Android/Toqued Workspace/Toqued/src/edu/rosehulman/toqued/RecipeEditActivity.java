package edu.rosehulman.toqued;

import java.util.ArrayList;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.Toast;

public class RecipeEditActivity extends Activity implements OnClickListener {
	
	private EditText mTitle;
	private EditText mIngredients;
	private EditText mInstructions;
	private ImageView mPhoto;
	private Button mPrev;
	private Button mNext;
	private int mSlideNumber = 0;
	private int mEndNumber;
	private int mOriginalNumber;
	private int mId;
	private RecipeStructure mRecipe;
	private DatabaseBackend mDbAdapter;
	private ArrayList<RecipeStep> mSteps;
	private Boolean isNew;
	
	private ArrayList<FridgeItemStructure> mIngredientList;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_recipe_edit);
        
        Intent i = this.getIntent();
        mId = i.getIntExtra(getString(R.string.key_recipe_id), 13);	//lucky number 13...
        
        mDbAdapter = new DatabaseBackend(this);
        mDbAdapter.open();
        
//        mRecipe = new RecipeStructure();
        mRecipe = mDbAdapter.getRecipeById(mId);
        
        
        //check if steps exist, otherwise create a new one
        isNew = false;
        mSteps = mDbAdapter.getStepsByRecipeId(mId);
        mOriginalNumber = mSteps.size()+1;
        if(mSteps.size() == 0){
        	mSteps = new ArrayList<RecipeStep>();
        	isNew = true;
        	
        }
        mSteps.add(0,new RecipeStep());
        
        
        mTitle = (EditText) findViewById(R.id.title_edit_text);
        mIngredients = (EditText) findViewById(R.id.ingredients_edit_text);
        mInstructions = (EditText) findViewById(R.id.instruction_edit_text);
        mPhoto = (ImageView) findViewById(R.id.recipe_image_view_edit);
        
        mPhoto.setOnLongClickListener(new View.OnLongClickListener() {
			
			public boolean onLongClick(View v) {
				Toast.makeText(RecipeEditActivity.this, "Add an image for slide " + mSlideNumber, Toast.LENGTH_SHORT).show();
				return true;
			}
		});
        
        mPrev = (Button) findViewById(R.id.edit_previous_button);
        mNext = (Button) findViewById(R.id.edit_next_button);
        
        mPrev.setOnClickListener(this);
        mNext.setOnClickListener(this);
        
        mEndNumber = mSteps.size(); 
        
        refreshScreen();
        
        mTitle.setHint(mRecipe.getRecipeName());
    }
    
	@Override
	protected void onDestroy() {
		super.onDestroy();
		mDbAdapter.close();
	}

	@Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_recipe_edit, menu);
        return true;
    }
	
	
	@Override
	public boolean onMenuItemSelected(int featureId, MenuItem item) {
		switch(item.getItemId()){
		case R.id.menu_edit_ingredients:
			final Dialog viewIngredientDialog = new Dialog(RecipeEditActivity.this);
			viewIngredientDialog.setContentView(R.layout.recipe_ingredient_view);
			viewIngredientDialog.setTitle(R.string.view_ingredients);
			
			mIngredientList = new ArrayList<FridgeItemStructure>();
			if(mIngredientList.size() == 0){
				mIngredientList.add(new FridgeItemStructure("Add an item", 0, "", DatabaseBackend.FRIDGE_LOCATIONS.LIST));
			}else{
				mIngredientList.remove(new FridgeItemStructure("Add an item", 0, "", DatabaseBackend.FRIDGE_LOCATIONS.LIST));
			}
			final ListView ingredientListView = (ListView) viewIngredientDialog.findViewById(R.id.recipe_ingredient_list_view);
			final ItemAdapter ingredientAdapter = new ItemAdapter(RecipeEditActivity.this, R.layout.list_item, mIngredientList);
			ingredientListView.setAdapter(ingredientAdapter);
			
			ingredientListView.setOnItemLongClickListener( new OnItemLongClickListener() {

				public boolean onItemLongClick(AdapterView<?> parent, View v, int position, long id) {
					final int pos = position;
					
					//Create the dialog builder and set items
					AlertDialog.Builder editDialog = new AlertDialog.Builder(RecipeEditActivity.this);
					editDialog.setTitle(R.string.item_selection);
					editDialog.setInverseBackgroundForced(true);
					editDialog.setItems(R.array.item_choice_array_limited, new DialogInterface.OnClickListener() {
						public void onClick(DialogInterface dialog, int which) {
							Resources r = getResources();
							String[] choices = r.getStringArray(R.array.item_choice_array_limited);
							//Create add, edit, and delete dialogs off a switch case
							switch (which) {
							case 0:	//Add
								Log.d(MainMenuActivity.TQD, "Add an item");
								//Create dialog inside dialog for add functionality
								final Dialog addItemDialog = new Dialog(RecipeEditActivity.this);
								addItemDialog.setContentView(R.layout.activity_refrigerator_item);
								addItemDialog.setTitle(R.string.add_ingredient);
								
								//Pull in fields for item name, quantity, and unit
								final EditText itemName = (EditText) addItemDialog.findViewById(R.id.fridge_item_name);
								final EditText itemQuantity = (EditText) addItemDialog.findViewById(R.id.fridge_item_qty);
								final Spinner itemUnit = (Spinner) addItemDialog.findViewById(R.id.fridge_item_unit);
								
								//Create array adapter for the spinner
								ArrayAdapter<CharSequence> englishUnits = ArrayAdapter.createFromResource(RecipeEditActivity.this, R.array.english_unit_array, android.R.layout.simple_spinner_item);
								englishUnits.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
								itemUnit.setAdapter(englishUnits);
								
								//Click listener for add item button
								((Button) addItemDialog.findViewById(R.id.fridge_item_add_button)).setOnClickListener(new View.OnClickListener() {
									public void onClick(View v) {
										//Add the item to the proper shelf from the edittext, then update the adapter
										
										if(itemName.getText().toString().equals("")){
											Toast.makeText(RecipeEditActivity.this, "Please input an item name", Toast.LENGTH_LONG).show();
											addItemDialog.dismiss();
											return;
										}
										
										double quantity = 0;
										try{
											quantity = Integer.parseInt(itemQuantity.getText().toString());
										}catch(Exception NumberFormatException){
											try{
												quantity = Double.parseDouble(itemQuantity.getText().toString());
											}catch(Exception DoubleFormatException){
												Log.d(MainMenuActivity.TQD, "number failure, bro");
												Toast.makeText(RecipeEditActivity.this, "Please input a numeric quantity", Toast.LENGTH_LONG).show();
												addItemDialog.dismiss();
												return;
											}
										}
										
										//TODO: add to db (add to items, then to the recipe db).  Currently not persistent.
										
//										FridgeItemStructure added = mDbAdapter.addItem(new FridgeItemStructure(itemName.getText().toString(), 
//																					quantity,
//																					itemUnit.getItemAtPosition(itemUnit.getLastVisiblePosition()).toString(),
//																					DatabaseBackend.FRIDGE_LOCATIONS.LIST));
//										mDbAdapter.addHasItem(added.getId(), added);
										
										mIngredientList.add(new FridgeItemStructure(itemName.getText().toString(), 
																					quantity,
																					itemUnit.getItemAtPosition(itemUnit.getLastVisiblePosition()).toString(),
																					DatabaseBackend.FRIDGE_LOCATIONS.LIST));
										ingredientAdapter.notifyDataSetChanged();
										
//										ingredientListView.setAdapter(new ItemAdapter(RecipeEditActivity.this, R.layout.list_item, mDbAdapter.currentItemsForId(added.getId())));
										
//										mIngredientList.remove(new FridgeItemStructure("Add an item", 0, "", DatabaseBackend.FRIDGE_LOCATIONS.LIST));
										Toast.makeText(RecipeEditActivity.this, "Added " + itemName.getText().toString(), Toast.LENGTH_LONG).show();
										addItemDialog.dismiss();
									}
								});
								
								//Listener for cancel button
								((Button) addItemDialog.findViewById(R.id.fridge_item_cancel_button)).setOnClickListener(new View.OnClickListener() {
									public void onClick(View v) {
										addItemDialog.dismiss();
									}
								});
								//Show the dialog!
								addItemDialog.show();
								break;
							case 1:	//Edit
								Log.d(MainMenuActivity.TQD, "Edit an item");
								
								//Create the edit dialog
								final Dialog editItemDialog = new Dialog(RecipeEditActivity.this);
								editItemDialog.setContentView(R.layout.activity_refrigerator_item);
								editItemDialog.setTitle(getString(R.string.fridge_edit_item_format, mIngredientList.get(pos).getItemName()));
								
								//Link up name, quantity, and unit inputs with the layout
								final EditText editName = (EditText) editItemDialog.findViewById(R.id.fridge_item_name);
								final EditText editQuantity = (EditText) editItemDialog.findViewById(R.id.fridge_item_qty);
								final Spinner editUnit = (Spinner) editItemDialog.findViewById(R.id.fridge_item_unit);
								
								//Create array adapter for the spinner
								ArrayAdapter<CharSequence> engUnits = ArrayAdapter.createFromResource(RecipeEditActivity.this, R.array.english_unit_array, android.R.layout.simple_spinner_item);
								engUnits.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
								editUnit.setAdapter(engUnits);
								
								//Pull the text from the selected item
								editName.setText(mIngredientList.get(pos).getItemName());
								editQuantity.setText(""+mIngredientList.get(pos).getQuantity());								
								//Populate the spinner from the already set unit
								String[] units = r.getStringArray(R.array.english_unit_array);
								int unitPosition = findPosition(units, mIngredientList.get(pos).getUnit());
								editUnit.setSelection(unitPosition);

								//Set the text and affix a button to the edit button
								((Button) editItemDialog.findViewById(R.id.fridge_item_add_button)).setText(R.string.edit);
								((Button) editItemDialog.findViewById(R.id.fridge_item_add_button)).setOnClickListener(new View.OnClickListener() {
									public void onClick(View v) {
										//Edit the proper item in place in the list, then toast.
										
										if(editName.getText().toString().equals("")){
											Toast.makeText(RecipeEditActivity.this, "Please input an item name", Toast.LENGTH_LONG).show();
											editItemDialog.dismiss();
											return;
										}
										
										//Try to parse the input, make sure it comes out properly!
										double quantity = 0;
										try{
											quantity = Integer.parseInt(editQuantity.getText().toString());
										}catch(Exception NumberFormatException){
											try{
												quantity = Double.parseDouble(editQuantity.getText().toString());
											}catch(Exception DoubleFormatException){
												Log.d(MainMenuActivity.TQD, "number failure, bro");
												Toast.makeText(RecipeEditActivity.this, "Please input a numeric quantity", Toast.LENGTH_LONG).show();
												editItemDialog.dismiss();
												return;
											}
										}
										
										//TODO: update in table
										mIngredientList.set(pos, new FridgeItemStructure(editName.getText().toString(), 
												quantity,
												editUnit.getItemAtPosition(editUnit.getLastVisiblePosition()).toString(),
												DatabaseBackend.FRIDGE_LOCATIONS.LIST));
										ingredientAdapter.notifyDataSetChanged();
										Toast.makeText(RecipeEditActivity.this, "Edited " + editName.getText().toString(), Toast.LENGTH_LONG).show();
										editItemDialog.dismiss();
									}
								});
								//Cancel button with on click functionality specified
								((Button) editItemDialog.findViewById(R.id.fridge_item_cancel_button)).setOnClickListener(new View.OnClickListener() {
									public void onClick(View v) {
										editItemDialog.dismiss();
									}
								});
								//Once again, show the dialog
								editItemDialog.show();
								break;
								
							case 2:	//Delete
								Log.d(MainMenuActivity.TQD, "Delete an item");
								
								//Delete dialog is essentially just a confirmation
								AlertDialog.Builder deleteDialog = new AlertDialog.Builder(RecipeEditActivity.this);
								deleteDialog.setTitle(getString(R.string.delete_item_string_format, mIngredientList.get(pos).getItemName()));
								
								//Retrieve item before it is deleted
								
								//Positive button deletes the item
								deleteDialog.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {	
									public void onClick(DialogInterface dialog, int which) {
										//TODO: delete item from recipes DB
										FridgeItemStructure removedItem = mIngredientList.remove(pos);
										ingredientAdapter.notifyDataSetChanged();
										if(mIngredientList.size() == 0){
											mIngredientList.add(new FridgeItemStructure("Add an item", 0, "", DatabaseBackend.FRIDGE_LOCATIONS.LIST));
										}
										Toast.makeText(RecipeEditActivity.this, "Deleted " + removedItem.getItemName(), Toast.LENGTH_LONG).show();
									}
								});
								
								//Negative button here is cancel, set the on click then dismiss the dialog
								deleteDialog.setNeutralButton(R.string.cancel, new DialogInterface.OnClickListener() {
									
									public void onClick(DialogInterface dialog, int which) {
										dialog.dismiss();
									}
								});
								
								//Show the dialog
								deleteDialog.show();
								break;
							}
							dialog.dismiss();
						}
					});
					editDialog.show();
					return true;
				}
			});
			viewIngredientDialog.show();
			return true;
			
		case R.id.menu_save_recipe:
			if(isNew){
				//add
				saveRecipe();
			} else{
				//update
				updateRecipe();
			}
			return true;
		}
	
		return false;
	}

	public void onClick(View v) {
		//save changes from old slide automatically!
		
		RecipeStep temp;
		//increment or decrement slide count
		switch(v.getId()){
			case R.id.edit_previous_button:
				
				mSteps.get(mSlideNumber).setInstructions(mInstructions.getText().toString());
				mSlideNumber--;
				
				if(mSlideNumber>0){
					mInstructions.setText(mSteps.get(mSlideNumber).getInstructions());
				}
			break;
			
			case R.id.edit_next_button: 

				mSteps.get(mSlideNumber).setInstructions(mInstructions.getText().toString());
				mSlideNumber++;
				if(mSlideNumber > mSteps.size()-1){
					mSteps.add(new RecipeStep());
					mInstructions.setText("");
					mInstructions.setHint(getString(R.string.recipe_instruction_start));
				}else{
					if(mSlideNumber>0){
						mInstructions.setText(mSteps.get(mSlideNumber).getInstructions());
					}
				}
			break;
		}
		
		refreshScreen();
		
	}
	
	private void refreshScreen() {
		
		mEndNumber = mSteps.size();
		
        if(mSlideNumber == 0){
        	mPrev.setClickable(false);
        	mPrev.setTextColor(Color.GRAY);
        	mInstructions.setVisibility(View.GONE);
        	mIngredients.setVisibility(View.GONE);
        	mTitle.setVisibility(View.VISIBLE);
        }else if(mSlideNumber == mEndNumber && mSlideNumber > 0){
        	mNext.setClickable(false);
        	mNext.setTextColor(Color.GRAY);
        }else{
        	mInstructions.setVisibility(View.VISIBLE);
        	mTitle.setVisibility(View.GONE);
        	mIngredients.setVisibility(View.GONE);
        	mPrev.setClickable(true);
        	mNext.setClickable(true);
        	mPrev.setTextColor(Color.BLACK);
        	mNext.setTextColor(Color.BLACK);
        }
	}
	
	/*
	 * Finds the position of a string in an array of strings
	 * NOTE: ASSUMES THAT THE STRING IS THERE!!!!!!!!!!!
	 */
	private int findPosition(String[] units, String string) {
		for(int i = 0; i < units.length; i++){
			if(string.equals(units[i])){
				Log.d(MainMenuActivity.TQD, "Found " + units[i] + " matching "+ string + " at position " + i);
				return i;
			}
		}
		Log.d(MainMenuActivity.TQD, "Couldn't find a match for " + string);
		return 0;
	}
	
	private void saveRecipe(){
		if(!mInstructions.getText().toString().equals("")){
			mSteps.get(mSlideNumber).setInstructions(mInstructions.getText().toString());
		}
		for(int i = 0; i < mSteps.size(); i++){
			mSteps.get(i).setRecipeId(mId);
			mSteps.get(i).setStepNumber(i);
			Log.d(MainMenuActivity.TQD, "Recipe id: " + mId + " step " + i + " instruction " + mSteps.get(i).getInstructions() + " saved"); 
			if(!(mSteps.get(i).getInstructions().equals(""))){
				mDbAdapter.addStep(mSteps.get(i));
			}
		}
		Toast.makeText(this, "Recipe saved", Toast.LENGTH_SHORT).show();
		finish();
	}
	
	private void updateRecipe() {
		if(!mInstructions.getText().toString().equals("")){
			mSteps.get(mSlideNumber).setInstructions(mInstructions.getText().toString());
		}
		for(int i = 0; i < mSteps.size(); i++){
			mSteps.get(i).setRecipeId(mId);
			mSteps.get(i).setStepNumber(i);
			Log.d(MainMenuActivity.TQD, "Recipe id: " + mId + " step " + i + " instruction " + mSteps.get(i).getInstructions() + " saved");
			if(i < mOriginalNumber){
				if(!(mSteps.get(i).getInstructions().equals(""))){
					mDbAdapter.updateStep(mSteps.get(i));
				}else{
					mDbAdapter.deleteStep(mSteps.get(i));
				}
				
			}else{
				if(!(mSteps.get(i).getInstructions().equals(""))){
					mDbAdapter.addStep(mSteps.get(i));
				}
			}
		}
		Toast.makeText(this, "Recipe saved", Toast.LENGTH_SHORT).show();
		finish();
	}
}
