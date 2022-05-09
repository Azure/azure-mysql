<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCartItemsTable extends Migration
{
	/**
	 * Run the migrations.
	 *
	 * @return void
	 */
	public function up()
	{
		Schema::create('cart_items', function (Blueprint $table) {
			$table->id();
			$table->bigInteger('cart_id')->unsigned();
			$table->bigInteger('item_id')->unsigned();
			$table->unsignedSmallInteger('qty');
			$table->timestamps();
			$table->engine = 'InnoDB';
			$table->charset = 'utf8';
			$table->collation = 'utf8_general_ci';
		});
		Schema::table('cart_items', function (Blueprint $table) {
			$table->foreign('cart_id')->references('id')->on('carts')->onDelete('cascade');
			$table->foreign('item_id')->references('id')->on('items')->onDelete('cascade');
		});
	}

	/**
	 * Reverse the migrations.
	 *
	 * @return void
	 */
	public function down()
	{
		Schema::dropIfExists('cart_items');
	}
}
