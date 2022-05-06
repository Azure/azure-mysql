<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
	use HasFactory;

	public $timestamps = false;

	protected $fillable = [
		'name',
		'url',
		'img',
	];

	public function items()
	{
		return $this->hasMany(Item::class, 'category_id', 'id')->orderBy('name');
	}

}
