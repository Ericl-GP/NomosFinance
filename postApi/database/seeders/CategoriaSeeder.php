<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Categoria;

class CategoriaSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categorias = [
            ['name' => 'Alimentação'],
            ['name' => 'Transporte'],
            ['name' => 'Moradia'],
            ['name' => 'Outros'],
             ['name' => 'Lazer'],
             ['name' => 'Saúde'],
             ['name' => 'Educação'],
             ['name' => 'Roupas'],
             ['name' => 'Tecnologia'],
             ['name' => 'Viagem']
        ];

        foreach ($categorias as $categoria) {
            Categoria::updateOrCreate(['name' => $categoria['name']], $categoria);
        }
    }
}
