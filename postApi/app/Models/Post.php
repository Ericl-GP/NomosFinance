<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    protected $table = 'posts';

    protected $fillable = [
        'title',
        'content',
        'valor',
        'categoria_id',
        'recorrente',
        'user_id',
        'imagem',
        'data',
    ];
    protected $casts = [
    'data' => 'datetime',
    'recorrente' => 'boolean',
    'valor' => 'double',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function categoria()
    {
        return $this->belongsTo(Categoria::class);
    }
}