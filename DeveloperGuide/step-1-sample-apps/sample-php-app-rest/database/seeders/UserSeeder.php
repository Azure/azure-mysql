<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

use App\Models\User;

class UserSeeder extends Seeder
{
	/**
	 * Run the database seeds.
	 *
	 * @return void
	 */
	public function run()
	{
		// DB::table('users')->truncate();
		User::query()->delete();
		DB::statement("ALTER TABLE `users` AUTO_INCREMENT = 1");

		$users = [
			[
				'name' => 'Jon Yang',
				'address' => '3761 N. 14th St',
				'email' => 'jon24@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Eugene Huang',
				'address' => '2243 W St.',
				'email' => 'eugene10@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Ruben Torres',
				'address' => '5844 Linden Land',
				'email' => 'ruben35@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Christy Zhu',
				'address' => '1825 Village Pl.',
				'email' => 'christy12@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Elizabeth Johnson',
				'address' => '7553 Harness Circle',
				'email' => 'elizabeth5@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Julio Ruiz',
				'address' => '7305 Humphrey Drive',
				'email' => 'julio1@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Janet Alvarez',
				'address' => '2612 Berry Dr',
				'email' => 'janet9@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Marco Mehta',
				'address' => '942 Brook Street',
				'email' => 'marco14@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Rob Verhoff',
				'address' => '624 Peabody Road',
				'email' => 'rob4@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Shannon Carlson',
				'address' => '3839 Northgate Road',
				'email' => 'shannon38@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Jacquelyn Suarez',
				'address' => '7800 Corrinne Court',
				'email' => 'jacquelyn20@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Curtis Lu',
				'address' => '1224 Shoenic',
				'email' => 'curtis9@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Lauren Walker',
				'address' => '4785 Scott Street',
				'email' => 'lauren41@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Ian Jenkins',
				'address' => '7902 Hudson Ave.',
				'email' => 'ian47@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Sydney Bennett',
				'address' => '9011 Tank Drive',
				'email' => 'sydney23@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Chloe Young',
				'address' => '244 Willow Pass Road',
				'email' => 'chloe23@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Wyatt Hill',
				'address' => '9666 Northridge Ct.',
				'email' => 'wyatt32@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Shannon Wang',
				'address' => '7330 Saddlehill Lane',
				'email' => 'shannon1@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Clarence Rai',
				'address' => '244 Rivewview',
				'email' => 'clarence32@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Luke Lal',
				'address' => '7832 Landing Dr',
				'email' => 'luke18@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Jordan King',
				'address' => '7156 Rose Dr.',
				'email' => 'jordan73@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Destiny Wilson',
				'address' => '8148 W. Lake Dr.',
				'email' => 'destiny7@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Ethan Zhang',
				'address' => '1769 Nicholas Drive',
				'email' => 'ethan20@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Seth Edwards',
				'address' => '4499 Valley Crest',
				'email' => 'seth46@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Russell Xie',
				'address' => '8734 Oxford Place',
				'email' => 'russell7@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Alejandro Beck',
				'address' => '2596 Franklin Canyon Road',
				'email' => 'alejandro45@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Harold Sai',
				'address' => '8211 Leeds Ct.',
				'email' => 'harold3@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Jessie Zhao',
				'address' => '213 Valencia Place',
				'email' => 'jessie16@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Jill Jimenez',
				'address' => '9111 Rose Ann Ave',
				'email' => 'jill13@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Jimmy Moreno',
				'address' => '6385 Mark Twain',
				'email' => 'jimmy9@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Bethany Yuan',
				'address' => '636 Vine Hill Way',
				'email' => 'bethany10@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Theresa Ramos',
				'address' => '6465 Detroit Ave.',
				'email' => 'theresa13@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Denise Stone',
				'address' => '626 Bentley Street',
				'email' => 'denise10@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Jaime Nath',
				'address' => '5927 Rainbow Dr',
				'email' => 'jaime41@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Ebony Gonzalez',
				'address' => '5167 Condor Place',
				'email' => 'ebony19@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Wendy Dominguez',
				'address' => '1873 Mt. Whitney Dr',
				'email' => 'wendy12@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Jennifer Russell',
				'address' => '3981 Augustine Drive',
				'email' => 'jennifer93@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Chloe Garcia',
				'address' => '8915 Woodside Way',
				'email' => 'chloe27@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Diana Hernandez',
				'address' => '8357 Sandy Cove Lane',
				'email' => 'diana2@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Marc Martin',
				'address' => '9353 Creekside Dr.',
				'email' => 'marc3@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Jesse Murphy',
				'address' => '3350 Kingswood Circle',
				'email' => 'jesse15@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Amanda Carter',
				'address' => '5826 Escobar',
				'email' => 'amanda53@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Megan Sanchez',
				'address' => '1397 Paraiso Ct.',
				'email' => 'megan28@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Nathan Simmons',
				'address' => '1170 Shaw Rd',
				'email' => 'nathan11@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Adam Flores',
				'address' => '6935 Candle Dr',
				'email' => 'adam10@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Leonard Nara',
				'address' => '7466 La Vista Ave.',
				'email' => 'leonard18@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Christine Yuan',
				'address' => '2356 Orange St',
				'email' => 'christine4@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Jaclyn Lu',
				'address' => '2812 Mazatlan',
				'email' => 'jaclyn12@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Jeremy Powell',
				'address' => '1803 Potomac Dr.',
				'email' => 'jeremy26@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Carol Rai',
				'address' => '6064 Madrid',
				'email' => 'carol8@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Alan Zheng',
				'address' => '2741 Gainborough Dr.',
				'email' => 'alan23@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Daniel Johnson',
				'address' => '8085 Sunnyvale Avenue',
				'email' => 'daniel18@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Heidi Lopez',
				'address' => '2514 Via Cordona',
				'email' => 'heidi19@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Ana Price',
				'address' => '1660 Stonyhill Circle',
				'email' => 'ana0@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Deanna Munoz',
				'address' => '5825 B Way',
				'email' => 'deanna33@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Gilbert Raje',
				'address' => '8811 The Trees Dr.',
				'email' => 'gilbert35@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Michele Nath',
				'address' => '5464 Janin Pl.',
				'email' => 'michele19@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Carl Andersen',
				'address' => '6930 Lake Nadine Place',
				'email' => 'carl12@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Marc Diaz',
				'address' => '6645 Sinaloa',
				'email' => 'marc6@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Ashlee Andersen',
				'address' => '8255 Highland Road',
				'email' => 'ashlee19@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Jon Zhou',
				'address' => '6574 Hemlock Ave.',
				'email' => 'jon28@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Todd Gao',
				'address' => '8808 Geneva Ave',
				'email' => 'todd14@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Noah Powell',
				'address' => '9794 Marion Ct',
				'email' => 'noah5@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Angela Murphy',
				'address' => '4927 Virgil Street',
				'email' => 'angela41@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Chase Reed',
				'address' => '2721 Alexander Pl.',
				'email' => 'chase21@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Jessica Henderson',
				'address' => '9343 Ironwood Way',
				'email' => 'jessica29@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Grace Butler',
				'address' => '4739 Garden Ave.',
				'email' => 'grace62@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Caleb Carter',
				'address' => '9563 Pennsylvania Blvd.',
				'email' => 'caleb40@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Tiffany Liang',
				'address' => '3608 Sinclair Avenue',
				'email' => 'tiffany17@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Carolyn Navarro',
				'address' => '4606 Springwood Court',
				'email' => 'carolyn30@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Willie Raji',
				'address' => '6260 Vernal Drive',
				'email' => 'willie40@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Linda Serrano',
				'address' => '9808 Shaw Rd.',
				'email' => 'linda31@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Casey Luo',
				'address' => '9513 Roslyn Drive',
				'email' => 'casey6@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Amy Ye',
				'address' => '2262 Kirkwood Ct.',
				'email' => 'amy16@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Levi Arun',
				'address' => '4661 Bluetail',
				'email' => 'levi6@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Felicia Jimenez',
				'address' => '786 Eastgate Ave',
				'email' => 'felicia4@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Blake Anderson',
				'address' => '5436 Clear',
				'email' => 'blake9@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Leah Ye',
				'address' => '1291 Arguello Blvd.',
				'email' => 'leah7@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Gina Martin',
				'address' => '1349 Sol St.',
				'email' => 'gina1@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Donald Gonzalez',
				'address' => '4236 Malibu Place',
				'email' => 'donald20@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Damien Chander',
				'address' => '9941 Stonehedge Dr.',
				'email' => 'damien32@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Savannah Baker',
				'address' => '1210 Trafalgar Circle',
				'email' => 'savannah39@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Angela Butler',
				'address' => '6040 Listing Ct',
				'email' => 'angela17@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Alyssa Cox',
				'address' => '867 La Orinda Place',
				'email' => 'alyssa37@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Lucas Phillips',
				'address' => '8668 St. Celestine Court',
				'email' => 'lucas7@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Emily Johnson',
				'address' => '7926 Stephanie Way',
				'email' => 'emily1@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Ryan Brown',
				'address' => '2939 Wesley Ct.',
				'email' => 'ryan43@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Tamara Liang',
				'address' => '3791 Rossmor Parkway',
				'email' => 'tamara6@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Hunter Davis',
				'address' => '4308 Sand Pointe Lane',
				'email' => 'hunter64@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Abigail Price',
				'address' => '2685 Blackburn Ct',
				'email' => 'abigail25@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Trevor Bryant',
				'address' => '5781 Sharon Dr.',
				'email' => 'trevor18@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Dalton Perez',
				'address' => '6083 San Jose',
				'email' => 'dalton37@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Cheryl Diaz',
				'address' => '7297 Kaywood Drive',
				'email' => 'cheryl4@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Aimee He',
				'address' => '1833 Olympic Drive',
				'email' => 'aimee13@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Cedric Ma',
				'address' => '3407 Oak Brook Place',
				'email' => 'cedric15@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Chad Kumar',
				'address' => '1681 Lighthouse Way',
				'email' => 'chad9@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Andrés Anand',
				'address' => '5423 Los Gatos Ct.',
				'email' => 'andrés18@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Edwin Nara',
				'address' => '719 William Way',
				'email' => 'edwin39@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Mallory Rubio',
				'address' => '6452 Harris Circle',
				'email' => 'mallory7@adventure-works.com',
				'password' => Hash::make('password'),
			],
			[
				'name' => 'Adam Ross',
				'address' => '4378 Westminster Place',
				'email' => 'adam2@adventure-works.com',
				'password' => Hash::make('password'),
			],
		];
		User::insert($users);
	}
}
