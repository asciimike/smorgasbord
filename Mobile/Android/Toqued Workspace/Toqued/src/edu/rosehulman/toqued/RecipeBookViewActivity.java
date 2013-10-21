package edu.rosehulman.toqued;

import java.util.ArrayList;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;
import android.database.Cursor;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

public class RecipeBookViewActivity extends Activity implements OnItemClickListener, OnItemLongClickListener {
	
	private TextView mMealTitle;
	private ListView mRecipeList;
	private RecipeAdapter mRecipeListAdapter;
	private String mMeal;
	
	private ArrayList<RecipeStructure> mBreakfastRecipes = new ArrayList<RecipeStructure>();
	private ArrayList<RecipeStructure> mLunchRecipes = new ArrayList<RecipeStructure>();
	private ArrayList<RecipeStructure> mDinnerRecipes = new ArrayList<RecipeStructure>();
	private ArrayList<RecipeStructure> mDessertRecipes = new ArrayList<RecipeStructure>();
	private ArrayList<RecipeStructure> mSnackRecipes = new ArrayList<RecipeStructure>();
	
	private ArrayList<RecipeStructure> mAllRecipes;
	
	private DatabaseBackend mDbAdapter;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_recipe_book_list_view);
		
		mMeal = getIntent().getStringExtra(getString(R.string.KEY_MEAL_SELECTION));
		
		mMealTitle = (TextView) findViewById(R.id.recipe_book_meal_text_view);
		mMealTitle.setText(mMeal + " recipes:");
		
		mRecipeList = (ListView) findViewById(R.id.recipe_book_recipe_list);
		
		mRecipeListAdapter = null;
		
        mDbAdapter = new DatabaseBackend(this);
        mDbAdapter.open();
        
        updateFromDatabase();
        
		
		//TODO: Populate list with recipes...
		
//		mBreakfastRecipes.add(new RecipeStructure(1, "Pancakes", 32, "minute", 4));
//		
//		mLunchRecipes.add(new RecipeStructure(2, "Peanut Butter and Jelly", 1, "minute", 1));
//		
//		mDinnerRecipes.add(new RecipeStructure(3, "Salmon Filets with Balsamic Carrot Vinagrette", 3, "hour", 2));
//		
//		mDessertRecipes.add(new RecipeStructure(4, "Tiramisu", 30, "minute", 12));
//		
//		mSnackRecipes.add(new RecipeStructure(5, "Hot Ham and Cheese", 15, "minute", 1));
//		
//		mAllRecipes = new ArrayList<RecipeStructure>() {{addAll(mBreakfastRecipes); addAll(mLunchRecipes); addAll(mDinnerRecipes); addAll(mDessertRecipes); addAll(mSnackRecipes);}};
		

		
		//TODO: Short click = open recipe
		mRecipeList.setOnItemClickListener(this);
		
		//TODO: Long click = edit/delete?  maybe...
		mRecipeList.setOnItemLongClickListener(this);
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		mDbAdapter.close();
	}

	private void updateFromDatabase() {
		mBreakfastRecipes = new ArrayList<RecipeStructure>();
		mLunchRecipes = new ArrayList<RecipeStructure>();
		mDinnerRecipes = new ArrayList<RecipeStructure>();
		mDessertRecipes = new ArrayList<RecipeStructure>();
		mSnackRecipes = new ArrayList<RecipeStructure>();
		mAllRecipes = new ArrayList<RecipeStructure>();
		
		Cursor breakfastCursor = mDbAdapter.getRecipesCursor(DatabaseBackend.RECIPE_TYPE.BREAKFAST);
		Log.d(MainMenuActivity.TQD, "Number of breakfast items: " + breakfastCursor.getCount());
		breakfastCursor.moveToFirst();
		if(breakfastCursor!= null){
			if(breakfastCursor.getCount() != 0){
				do{
					mBreakfastRecipes.add(mDbAdapter.getRecipeFromCursor(breakfastCursor));
				}while(breakfastCursor.moveToNext());
			}
		}
		
		Cursor lunchCursor = mDbAdapter.getRecipesCursor(DatabaseBackend.RECIPE_TYPE.LUNCH);
		Log.d(MainMenuActivity.TQD, "Number of lunch items: " + lunchCursor.getCount());
		lunchCursor.moveToFirst();
		if(lunchCursor!= null){
			if (lunchCursor.getCount() != 0) {
				do {
					mLunchRecipes.add(mDbAdapter.getRecipeFromCursor(lunchCursor));
				} while (lunchCursor.moveToNext());
			}
		}
		
		Cursor dinnerCursor = mDbAdapter.getRecipesCursor(DatabaseBackend.RECIPE_TYPE.DINNER);
		Log.d(MainMenuActivity.TQD, "Number of dinner items: " + dinnerCursor.getCount());
		dinnerCursor.moveToFirst();
		if(dinnerCursor!= null){
			if(dinnerCursor.getCount() != 0){
				do {
					mDinnerRecipes.add(mDbAdapter.getRecipeFromCursor(dinnerCursor));
				} while(dinnerCursor.moveToNext());
			}
		}
		
		Cursor dessertCursor = mDbAdapter.getRecipesCursor(DatabaseBackend.RECIPE_TYPE.DESSERT);
		Log.d(MainMenuActivity.TQD, "Number of dessert items: " + dessertCursor.getCount());
		dessertCursor.moveToFirst();
		if(dessertCursor!= null){
			if(dessertCursor.getCount() != 0){
				do{
					mDessertRecipes.add(mDbAdapter.getRecipeFromCursor(dessertCursor));
				}while(dessertCursor.moveToNext());
			}
		}
		
		Cursor snackCursor = mDbAdapter.getRecipesCursor(DatabaseBackend.RECIPE_TYPE.SNACK);
		Log.d(MainMenuActivity.TQD, "Number of snack items: " + snackCursor.getCount());
		snackCursor.moveToFirst();
		if(snackCursor!= null){
			if(snackCursor.getCount() != 0){
				do {
					mSnackRecipes.add(mDbAdapter.getRecipeFromCursor(snackCursor));
				} while(snackCursor.moveToNext());
			}
		}
		
		mAllRecipes = new ArrayList<RecipeStructure>() {{addAll(mBreakfastRecipes); addAll(mLunchRecipes); addAll(mDinnerRecipes); addAll(mDessertRecipes); addAll(mSnackRecipes);}};
		
		mRecipeListAdapter = new RecipeAdapter(this, R.layout.list_item, new ArrayList<RecipeStructure>());
		
		Log.d(MainMenuActivity.TQD, "Meal is " + mMeal);
		
		if(mMeal.equals("Breakfast")){
			mRecipeListAdapter = new RecipeAdapter(this, R.layout.list_item, mBreakfastRecipes);
		}else if(mMeal.equals("Lunch")){
			mRecipeListAdapter = new RecipeAdapter(this, R.layout.list_item, mLunchRecipes);
		}else if(mMeal.equals("Dinner")){
			mRecipeListAdapter = new RecipeAdapter(this, R.layout.list_item, mDinnerRecipes);
		}else if(mMeal.equals("Dessert")){
			mRecipeListAdapter = new RecipeAdapter(this, R.layout.list_item, mDessertRecipes);
		}else if(mMeal.equals("Snack")){
			mRecipeListAdapter = new RecipeAdapter(this, R.layout.list_item, mSnackRecipes);
		}else if(mMeal.equals("Delete") || mMeal.equals("Edit")){
			mRecipeListAdapter = new RecipeAdapter(this, R.layout.list_item, mAllRecipes);
		}
		
		mRecipeList.setAdapter(mRecipeListAdapter);
	}

	public void onItemClick(AdapterView<?> parent, View c, int pos, long id) {
		Intent selectedIntent;
		selectedIntent = new Intent(this, RecipeViewActivity.class);
		//Change back to an int...
		RecipeStructure recipe = new RecipeStructure();
		if(mMeal.equals("Breakfast")){
			recipe = mBreakfastRecipes.get(pos);
		}else if(mMeal.equals("Lunch")){
			recipe = mLunchRecipes.get(pos);
		}else if(mMeal.equals("Dinner")){
			recipe = mDinnerRecipes.get(pos);
		}else if(mMeal.equals("Dessert")){
			recipe = mDessertRecipes.get(pos);
		}else if(mMeal.equals("Snack")){
			recipe = mSnackRecipes.get(pos);
		}else if(mMeal.equals("Edit")){
			recipe = mAllRecipes.get(pos);
			selectedIntent = new Intent(this, RecipeEditActivity.class);
		}else if(mMeal.equals("Delete")){
			Toast.makeText(this, "Deleting " + mAllRecipes.get(pos).getRecipeName(), Toast.LENGTH_SHORT).show();
			mDbAdapter.deleteRecipe(mAllRecipes.get(pos));
			updateFromDatabase();
			return;
		}
		//Pass an integer!
		
		selectedIntent.putExtra(getString(R.string.key_recipe_id), recipe.getId());
		this.startActivity(selectedIntent);
		
	}


	public boolean onItemLongClick(AdapterView<?> parent, View c, int pos, long id) {
		if(mMeal.equals("Delete") || mMeal.equals("Edit")){
			return false;
		}
		
		final int p = pos;
		AlertDialog.Builder editDialog = new AlertDialog.Builder(this);
		editDialog.setItems(R.array.edit_or_delete_recipe_array, new DialogInterface.OnClickListener() {
			
			public void onClick(DialogInterface dialog, int which) {
				if(which == 0){
					//edit
					Intent editIntent = new Intent(RecipeBookViewActivity.this, RecipeEditActivity.class);
					//Change back to an int...
					RecipeStructure recipe = new RecipeStructure();
					if(mMeal.equals("Breakfast")){
						recipe = mBreakfastRecipes.get(p);
					}else if(mMeal.equals("Lunch")){
						recipe = mLunchRecipes.get(p);
					}else if(mMeal.equals("Dinner")){
						recipe = mDinnerRecipes.get(p);
					}else if(mMeal.equals("Dessert")){
						recipe = mDessertRecipes.get(p);
					}else if(mMeal.equals("Snack")){
						recipe = mSnackRecipes.get(p);
					}
					//Pass an integer!
					editIntent.putExtra(getString(R.string.key_recipe_id), recipe.getId());
					RecipeBookViewActivity.this.startActivity(editIntent);
				}
				else{
					RecipeStructure temp = new RecipeStructure();
					//delete, need to make persistent
					if(mMeal.equals("Breakfast")){
						temp = mBreakfastRecipes.get(p);
					}else if(mMeal.equals("Lunch")){
						temp = mLunchRecipes.get(p);
					}else if(mMeal.equals("Dinner")){
						temp = mDinnerRecipes.get(p);
					}else if(mMeal.equals("Dessert")){
						temp = mDessertRecipes.get(p);
					}else if(mMeal.equals("Snack")){
						temp = mSnackRecipes.get(p);
					}
					Toast.makeText(RecipeBookViewActivity.this, "Deleting " + temp.getRecipeName(), Toast.LENGTH_SHORT).show();
					mDbAdapter.deleteRecipe(temp);
					updateFromDatabase();
				}
				
			}

		});
		editDialog.show();
		return false;
	}
	
	private void updateLists() {
		mRecipeListAdapter.notifyDataSetChanged();
		mAllRecipes = new ArrayList<RecipeStructure>() {{addAll(mBreakfastRecipes); addAll(mLunchRecipes); addAll(mDinnerRecipes); addAll(mDessertRecipes); addAll(mSnackRecipes);}};
	}
}
