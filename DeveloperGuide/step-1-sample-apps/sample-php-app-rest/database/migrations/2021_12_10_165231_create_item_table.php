<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateItemTable extends Migration
{
	/**
	 * Run the migrations.
	 *
	 * @return void
	 */
	public function up()
	{
		Schema::create('items', function (Blueprint $table) {
			$table->id();
			$table->bigInteger('category_id')->unsigned();
			$table->string('name', 32);
			$table->string('img', 128);
			$table->decimal('price', $precision = 6, $scale = 2);
			$table->unsignedSmallInteger('cooktime');
			$table->text('desc');
			$table->engine = 'InnoDB';
			$table->charset = 'utf8';
			$table->collation = 'utf8_general_ci';
		});
		Schema::table('items', function (Blueprint $table) {
			$table->foreign('category_id')->references('id')->on('categories')->onDelete('cascade');
		});
	}

	/**
	 * Reverse the migrations.
	 *
	 * @return void
	 */
	public function down()
	{
		Schema::dropIfExists('items');
	}
}
