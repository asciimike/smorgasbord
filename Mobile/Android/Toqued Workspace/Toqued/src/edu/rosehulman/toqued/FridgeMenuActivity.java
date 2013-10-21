package edu.rosehulman.toqued;

import java.util.ArrayList;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.res.Resources;
import android.database.Cursor;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnLongClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

public class FridgeMenuActivity extends Activity implements OnItemClickListener, OnItemLongClickListener, OnLongClickListener {

	private TextView mFridgeText;
	private ListView mFridgeItemsView;
	
	//Store the shelf items and list items separately
	private ArrayList<FridgeItemStructure> mShelfFridgeItems = new ArrayList<FridgeItemStructure>();
	private ArrayList<FridgeItemStructure> mListFridgeItems = new ArrayList<FridgeItemStructure>();
	
	private DatabaseBackend mDbAdapter;

	//Tells us if we are in the shelf or on the list
	private boolean isShelf = true;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_refrigerator);
        
        Resources r = this.getResources();
        String[] englishUnits = r.getStringArray(R.array.english_unit_array);
        
        //Grab text view
        mFridgeText = (TextView) findViewById(R.id.fridge_screen_text_view);
        mFridgeText.setText(R.string.fridge_shelf_title);
        
        //Grab list view
        mFridgeItemsView = (ListView) findViewById(R.id.fridge_item_list);
        
        //TODO: Populate arraylists with real data...
        mDbAdapter = new DatabaseBackend(this);
        mDbAdapter.open();
        
        updateFromDatabase();
        
        
        
        //Populate items lists with dummy data, this will be auto populated later on in the app
//        mShelfFridgeItems.add(new FridgeItemStructure("Apple", 1, englishUnits[1]));
//        mShelfFridgeItems.add(new FridgeItemStructure("Orange", 3, englishUnits[0]));
//        mShelfFridgeItems.add(new FridgeItemStructure("Banana", 5, englishUnits[3]));
//        mShelfFridgeItems.add(new FridgeItemStructure("Lemon", 7, englishUnits[2]));
//        mShelfFridgeItems.add(new FridgeItemStructure("Lime", 9, englishUnits[4]));
        
//        mListFridgeItems.add(new FridgeItemStructure("Apple 2", 1, englishUnits[1]));
//        mListFridgeItems.add(new FridgeItemStructure("Orange 2", 3, englishUnits[0]));
//        mListFridgeItems.add(new FridgeItemStructure("Banana 2", 5, englishUnits[3]));
//        mListFridgeItems.add(new FridgeItemStructure("Lemon 2", 7, englishUnits[2]));
//        mListFridgeItems.add(new FridgeItemStructure("Lime 2", 9, englishUnits[4]));

        //Create listview adapter and set it to the shelf       
//        ArrayAdapter<FridgeItemStructure> adapter = new ArrayAdapter<FridgeItemStructure>(this, R.layout.single_item, mShelfFridgeItems);
        
        ArrayAdapter<FridgeItemStructure> adapter = new ItemAdapter(this, R.layout.list_item, mShelfFridgeItems);
        mFridgeItemsView.setAdapter(adapter);
        
        //Set click listeners for the listview
        mFridgeItemsView.setOnItemClickListener(this);
        mFridgeItemsView.setOnItemLongClickListener(this);
        mFridgeItemsView.setOnLongClickListener(this);
        
      //TODO: Populate menus?  Start on the shelf or the list, depending on which last one was on (shared preferences and keys, yo)
      //TODO: Short press shows comments, opens FridgeItemCommentActivity/Dialog
      //TODO: Long press shows add, delete, edit item, pops a Dialog to select, then opens FridgeItemActivity/Dialog
    }
    
	@Override
	protected void onDestroy() {
		super.onDestroy();
		mDbAdapter.close();
	}

   private void updateFromDatabase() {
	   mShelfFridgeItems = new ArrayList<FridgeItemStructure>();
	   mListFridgeItems  = new ArrayList<FridgeItemStructure>();
	   
		Cursor shelfCursor = mDbAdapter.getItemsCursor(DatabaseBackend.FRIDGE_LOCATIONS.SHELF);
		if(shelfCursor!= null){
			if(shelfCursor.getCount() != 0){
				shelfCursor.moveToFirst();
//				mShelfFridgeItems.add(mDbAdapter.getItemFromCursor(shelfCursor));
				do{
					mShelfFridgeItems.add(mDbAdapter.getItemFromCursor(shelfCursor));
				}while(shelfCursor.moveToNext());
			}
		}
		
		Cursor listCursor = mDbAdapter.getItemsCursor(DatabaseBackend.FRIDGE_LOCATIONS.LIST);
		if(listCursor!= null){
			listCursor.moveToFirst();
//			mListFridgeItems.add(mDbAdapter.getItemFromCursor(listCursor));
			if(listCursor.getCount() != 0){
				do{
					mListFridgeItems.add(mDbAdapter.getItemFromCursor(listCursor));
				}while(listCursor.moveToNext());
			}
		}
	}
   
   /*
    * CRUD methods for adding, deleting, and updating the DB!
    */
   
	private void addItem(FridgeItemStructure item) {
		Log.d(MainMenuActivity.TQD, "Adding an item to the DB");
//		Toast.makeText(this, "Adding task: " + task, Toast.LENGTH_SHORT).show();
		item = mDbAdapter.addItem(item);
		updateFromDatabase();
		Log.d(MainMenuActivity.TQD, "Added "+ item.getItemName());
	}
	
	private void removeItem(FridgeItemStructure item) {
		mDbAdapter.deleteItem(item);
		updateFromDatabase();
		Log.d(MainMenuActivity.TQD, "Deleted "+ item.getItemName());
	}
	
	private void updateItem(FridgeItemStructure item) {
		mDbAdapter.updateItem(item);
		updateFromDatabase();
		Log.d(MainMenuActivity.TQD, "Updated "+ item.getId());
	}

 @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_refrigerator, menu);
        return true;
    }
    
    //Switch between list and shelf views, update the adaptor to the new view
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	switch (item.getItemId()) {
		case R.id.shelf_menu_option:
			Log.d(MainMenuActivity.TQD, "Changed to shelf");
			isShelf = true;
			mFridgeText.setText(R.string.fridge_shelf_title);
			updateFromDatabase();
			mFridgeItemsView.setAdapter(new ItemAdapter(this, R.layout.list_item, mShelfFridgeItems));
			break;

		case R.id.list_menu_option:
			Log.d(MainMenuActivity.TQD, "Changed to list");
			isShelf = false;
			mFridgeText.setText(R.string.fridge_list_title);
			updateFromDatabase();
			mFridgeItemsView.setAdapter(new ItemAdapter(this, R.layout.list_item, mListFridgeItems));
			break;
			
		case R.id.add_item:
			final Dialog addItemDialog = new Dialog(FridgeMenuActivity.this);
			addItemDialog.setContentView(R.layout.activity_refrigerator_item);
			addItemDialog.setTitle(R.string.fridge_add_item);
			
			//Pull in fields for item name, quantity, and unit
			final EditText itemName = (EditText) addItemDialog.findViewById(R.id.fridge_item_name);
			final EditText itemQuantity = (EditText) addItemDialog.findViewById(R.id.fridge_item_qty);
			final Spinner itemUnit = (Spinner) addItemDialog.findViewById(R.id.fridge_item_unit);
			
			//Create array adapter for the spinner
			ArrayAdapter<CharSequence> englishUnits = ArrayAdapter.createFromResource(FridgeMenuActivity.this, R.array.english_unit_array, android.R.layout.simple_spinner_item);
			englishUnits.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
			itemUnit.setAdapter(englishUnits);
			
			//Click listener for add item button
			((Button) addItemDialog.findViewById(R.id.fridge_item_add_button)).setOnClickListener(new View.OnClickListener() {
				

				public void onClick(View v) {
					//Add the item to the proper shelf from the edittext, then update the adapter
					
					if(itemName.getText().toString().equals("")){
						Toast.makeText(FridgeMenuActivity.this, "Please input an item name", Toast.LENGTH_LONG).show();
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
							Toast.makeText(FridgeMenuActivity.this, "Please input a numeric quantity", Toast.LENGTH_LONG).show();
							addItemDialog.dismiss();
							return;
						}
					}
					
					if(isShelf){
						addItem(new FridgeItemStructure(itemName.getText().toString(),
								quantity,
								itemUnit.getItemAtPosition(itemUnit.getLastVisiblePosition()).toString(),
								DatabaseBackend.FRIDGE_LOCATIONS.SHELF
								));
						mFridgeItemsView.setAdapter(new ItemAdapter(FridgeMenuActivity.this, R.layout.list_item, mShelfFridgeItems));
					}else{
						addItem(new FridgeItemStructure(itemName.getText().toString(),
								quantity,
								itemUnit.getItemAtPosition(itemUnit.getLastVisiblePosition()).toString(),
								DatabaseBackend.FRIDGE_LOCATIONS.LIST
								));
						mFridgeItemsView.setAdapter(new ItemAdapter(FridgeMenuActivity.this, R.layout.list_item, mListFridgeItems));
					}
					Toast.makeText(FridgeMenuActivity.this, "Added " + itemName.getText().toString(), Toast.LENGTH_SHORT).show();
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
		
		default:
			break;
		}
		return false;
    }

	public void onItemClick(AdapterView<?> l, View v, int position, long id) {
		Toast.makeText(this, "Short click at " + position, Toast.LENGTH_LONG).show();
		//TODO: Open the comments window.  Or maybe not.  IDK
	}

	//Used for long clicks, which are for add, edit, and delete a particular item from the list.  Add will also potentially be accomplished from off the view
	public boolean onItemLongClick(AdapterView<?> l, View v, int position, long id) {
		//Get the position for use in the inner class (doesn't like it being pulled from a parameter)
		final int pos = position;
		
		//Create the dialog builder and set items
		AlertDialog.Builder editDialog = new AlertDialog.Builder(this);
		editDialog.setTitle(R.string.item_selection);
		editDialog.setInverseBackgroundForced(true);
		editDialog.setItems(R.array.item_choice_array, new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				Resources r = getResources();
				String[] choices = r.getStringArray(R.array.recipe_choice_array);
				//Create add, edit, and delete dialogs off a switch case
				switch (which) {
				case 0:	//Add
					Log.d(MainMenuActivity.TQD, "Add an item");
					//Create dialog inside dialog for add functionality
					final Dialog addItemDialog = new Dialog(FridgeMenuActivity.this);
					addItemDialog.setContentView(R.layout.activity_refrigerator_item);
					addItemDialog.setTitle(R.string.fridge_add_item);
					
					//Pull in fields for item name, quantity, and unit
					final EditText itemName = (EditText) addItemDialog.findViewById(R.id.fridge_item_name);
					final EditText itemQuantity = (EditText) addItemDialog.findViewById(R.id.fridge_item_qty);
					final Spinner itemUnit = (Spinner) addItemDialog.findViewById(R.id.fridge_item_unit);
					
					//Create array adapter for the spinner
					ArrayAdapter<CharSequence> englishUnits = ArrayAdapter.createFromResource(FridgeMenuActivity.this, R.array.english_unit_array, android.R.layout.simple_spinner_item);
					englishUnits.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
					itemUnit.setAdapter(englishUnits);
					
					//Click listener for add item button
					((Button) addItemDialog.findViewById(R.id.fridge_item_add_button)).setOnClickListener(new View.OnClickListener() {
						

						public void onClick(View v) {
							//Add the item to the proper shelf from the edittext, then update the adapter
							
							if(itemName.getText().toString().equals("")){
								Toast.makeText(FridgeMenuActivity.this, "Please input an item name", Toast.LENGTH_LONG).show();
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
									Toast.makeText(FridgeMenuActivity.this, "Please input a numeric quantity", Toast.LENGTH_LONG).show();
									addItemDialog.dismiss();
									return;
								}
							}
							
							if(isShelf){
								addItem(new FridgeItemStructure(itemName.getText().toString(),
										quantity,
										itemUnit.getItemAtPosition(itemUnit.getLastVisiblePosition()).toString(),
										DatabaseBackend.FRIDGE_LOCATIONS.SHELF
										));
								mFridgeItemsView.setAdapter(new ItemAdapter(FridgeMenuActivity.this, R.layout.list_item, mShelfFridgeItems));
							}else{
								addItem(new FridgeItemStructure(itemName.getText().toString(),
										quantity,
										itemUnit.getItemAtPosition(itemUnit.getLastVisiblePosition()).toString(),
										DatabaseBackend.FRIDGE_LOCATIONS.LIST
										));
								mFridgeItemsView.setAdapter(new ItemAdapter(FridgeMenuActivity.this, R.layout.list_item, mListFridgeItems));
							}
							Toast.makeText(FridgeMenuActivity.this, "Added " + itemName.getText().toString(), Toast.LENGTH_SHORT).show();
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
					final Dialog editItemDialog = new Dialog(FridgeMenuActivity.this);
					editItemDialog.setContentView(R.layout.activity_refrigerator_item);
					editItemDialog.setTitle(getString(R.string.fridge_edit_item_format,isShelf ? mShelfFridgeItems.get(pos).getItemName() : mListFridgeItems.get(pos).getItemName()));
					
					//Link up name, quantity, and unit inputs with the layout
					final EditText editName = (EditText) editItemDialog.findViewById(R.id.fridge_item_name);
					final EditText editQuantity = (EditText) editItemDialog.findViewById(R.id.fridge_item_qty);
					final Spinner editUnit = (Spinner) editItemDialog.findViewById(R.id.fridge_item_unit);
					
					//Create array adapter for the spinner
					ArrayAdapter<CharSequence> engUnits = ArrayAdapter.createFromResource(FridgeMenuActivity.this, R.array.english_unit_array, android.R.layout.simple_spinner_item);
					engUnits.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
					editUnit.setAdapter(engUnits);
					
					//Pull the text from the selected item
					editName.setText(isShelf ? mShelfFridgeItems.get(pos).getItemName() : mListFridgeItems.get(pos).getItemName());
					editQuantity.setText(isShelf ? ""+ mShelfFridgeItems.get(pos).getQuantity() : ""+ mListFridgeItems.get(pos).getQuantity());
					
					//Populate the spinner from the already set unit
					String[] units = r.getStringArray(R.array.english_unit_array);
					int unitPosition = findPosition(units, isShelf ? mShelfFridgeItems.get(pos).getUnit() : mListFridgeItems.get(pos).getUnit());
					editUnit.setSelection(unitPosition);

					//Set the text and affix a button to the edit button
					((Button) editItemDialog.findViewById(R.id.fridge_item_add_button)).setText(R.string.edit);
					((Button) editItemDialog.findViewById(R.id.fridge_item_add_button)).setOnClickListener(new View.OnClickListener() {
						public void onClick(View v) {
							//Edit the proper item in place in the list, then toast.
							
							if(editName.getText().toString().equals("")){
								Toast.makeText(FridgeMenuActivity.this, "Please input an item name", Toast.LENGTH_LONG).show();
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
									Toast.makeText(FridgeMenuActivity.this, "Please input a numeric quantity", Toast.LENGTH_LONG).show();
									editItemDialog.dismiss();
									return;
								}
							}
							
							FridgeItemStructure temp = new FridgeItemStructure();
							if(isShelf){
								temp = mShelfFridgeItems.get(pos);
								temp.setItemName(editName.getText().toString());
								temp.setQuantity(quantity);
								temp.setUnit(editUnit.getItemAtPosition(editUnit.getLastVisiblePosition()).toString());
								//TODO: change these to update
//								mShelfFridgeItems.set(pos, new FridgeItemStructure(editName.getText().toString(),
//										quantity,
//										editUnit.getItemAtPosition(editUnit.getLastVisiblePosition()).toString(),
//										DatabaseBackend.FRIDGE_LOCATIONS.SHELF));
								updateItem(temp);
								mFridgeItemsView.setAdapter(new ItemAdapter(FridgeMenuActivity.this, R.layout.list_item, mShelfFridgeItems));
							}else{
								temp = mListFridgeItems.get(pos);
								temp.setItemName(editName.getText().toString());
								temp.setQuantity(quantity);
								temp.setUnit(editUnit.getItemAtPosition(editUnit.getLastVisiblePosition()).toString());
//								mListFridgeItems.set(pos, new FridgeItemStructure(editName.getText().toString(),
//										quantity,
//										editUnit.getItemAtPosition(editUnit.getLastVisiblePosition()).toString(),
//										DatabaseBackend.FRIDGE_LOCATIONS.LIST));
								updateItem(temp);
								mFridgeItemsView.setAdapter(new ItemAdapter(FridgeMenuActivity.this, R.layout.list_item, mListFridgeItems));
							}
							Toast.makeText(FridgeMenuActivity.this, "Edited " + editName.getText().toString(), Toast.LENGTH_LONG).show();
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
					AlertDialog.Builder deleteDialog = new AlertDialog.Builder(FridgeMenuActivity.this);
					deleteDialog.setTitle(R.string.delete_item_confirm);
					deleteDialog.setMessage(getString(R.string.delete_item_string_format, isShelf ? mShelfFridgeItems.get(pos).getItemName() : mListFridgeItems.get(pos).getItemName()));
					
					//Retrieve item before it is deleted
					final String item = isShelf ? mShelfFridgeItems.get(pos).getItemName() : mListFridgeItems.get(pos).getItemName();
					
					//Positive button deletes the item
					deleteDialog.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {	
						public void onClick(DialogInterface dialog, int which) {
							if(isShelf){
								removeItem(mShelfFridgeItems.get(pos));
//								mShelfFridgeItems.remove(pos);
								mFridgeItemsView.setAdapter(new ItemAdapter(FridgeMenuActivity.this, R.layout.list_item, mShelfFridgeItems));
							}else{
								removeItem(mListFridgeItems.get(pos));
//								mListFridgeItems.remove(pos);
								mFridgeItemsView.setAdapter(new ItemAdapter(FridgeMenuActivity.this, R.layout.list_item, mListFridgeItems));
							}
							Toast.makeText(FridgeMenuActivity.this, "Deleted " + item, Toast.LENGTH_LONG).show();
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
					
				case 3:
					AlertDialog.Builder swapDialog = new AlertDialog.Builder(FridgeMenuActivity.this);
					swapDialog.setTitle(R.string.delete_item_confirm);
					if(isShelf){
						swapDialog.setMessage(getString(R.string.swap_item_list_string_format, mShelfFridgeItems.get(pos).getItemName()));
					}else{
						swapDialog.setMessage(getString(R.string.swap_item_shelf_string_format, mListFridgeItems.get(pos).getItemName()));
					}
					
					
					//Positive button deletes the item
					swapDialog.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {	
						public void onClick(DialogInterface dialog, int which) {
							FridgeItemStructure temp = new FridgeItemStructure();
							if(isShelf){
								temp = mShelfFridgeItems.get(pos);
								temp.setLocation(DatabaseBackend.FRIDGE_LOCATIONS.LIST);
								updateItem(temp);
//								updateFromDatabase();
//								mListFridgeItems.add(mShelfFridgeItems.remove(pos));
								mFridgeItemsView.setAdapter(new ItemAdapter(FridgeMenuActivity.this, R.layout.list_item, mShelfFridgeItems));
							}else{
								temp = mListFridgeItems.get(pos);
								temp.setLocation(DatabaseBackend.FRIDGE_LOCATIONS.SHELF);
								updateItem(temp);
//								updateFromDatabase();
//								mShelfFridgeItems.add(mListFridgeItems.remove(pos));
								mFridgeItemsView.setAdapter(new ItemAdapter(FridgeMenuActivity.this, R.layout.list_item, mListFridgeItems));
							}
						}
					});
					
					//Negative button here is cancel, set the on click then dismiss the dialog
					swapDialog.setNeutralButton(R.string.cancel, new DialogInterface.OnClickListener() {
						
						public void onClick(DialogInterface dialog, int which) {
							dialog.dismiss();
						}
					});
					
					//Show the dialog
					swapDialog.show();
					break;
				}
				
				//Dismiss the old dialog
				dialog.dismiss();
			}
		});
		
		//Neutral button at the bottom of the main screen is cancel, which dismisses the outer dialog
		editDialog.setNeutralButton(R.string.cancel, new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		//Show the main outside dialog
		editDialog.show();
		return false;
	}

	/*
	 * (non-Javadoc)
	 * @see android.view.View.OnLongClickListener#onLongClick(android.view.View)
	 * 
	 * Same basic framework as above, but for the whole screen... so just add functionality.  Can pull the same stuff in from above.
	 * For adding an item when there are none
	 * Currently doesn't work... since the whole screen doesn't seem to be clickable
	 * TODO: Make this work... long click on screen with no items???
	 */
	public boolean onLongClick(View v) {
		AlertDialog.Builder addDialog = new AlertDialog.Builder(this);
		addDialog.setTitle(R.string.item_selection);
		addDialog.setItems(R.string.item_add, new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				Resources r = getResources();
				String choice = r.getString(R.string.item_add);
				switch (which) {
				case 0:	//Add
					Log.d(MainMenuActivity.TQD, "Add an item");
					//TODO: Got to the edit dialog but make it blank... offer slightly different options
					break;
				}
				dialog.dismiss();
			}
		});
		
		//Cancel button!
		addDialog.setNeutralButton(R.string.cancel, new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		
		//Show the dialog
		addDialog.show();
		return false;
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


}
