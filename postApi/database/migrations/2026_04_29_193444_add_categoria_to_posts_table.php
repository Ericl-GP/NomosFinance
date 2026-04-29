<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    

public function up()
{
    Schema::table('posts', function (Blueprint $table) {
            $table->decimal('valor', 10, 2)->after('content');

            $table->foreignId('categoria_id')
                  ->constrained('categorias')
                  ->cascadeOnDelete();

            $table->boolean('recorrente')->default(false);
        });
}

public function down()
{
     Schema::table('posts', function (Blueprint $table) {
            $table->dropForeign(['categoria_id']);
            $table->dropColumn(['valor', 'categoria_id', 'recorrente']);
        });
}
};
