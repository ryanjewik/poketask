
    INSERT INTO abilities_table (ability_id, ability_name, type, uses, hitrate, value)
    VALUES ('cca84005-5a30-4e0d-a6df-1a8fa61654ad', 'Tackle', 'Normal', 35, 95, 40);
    

    INSERT INTO abilities_table (ability_id, ability_name, type, uses, hitrate, value)
    VALUES ('8c4cfe4d-479f-4fb7-9403-6fc2a0bd0520', 'Vine Whip', 'Grass', 25, 100, 45);
    

    INSERT INTO abilities_table (ability_id, ability_name, type, uses, hitrate, value)
    VALUES ('09dfc037-616a-4274-8a9a-e26f03229738', 'Ember', 'Fire', 25, 100, 40);
    

    INSERT INTO abilities_table (ability_id, ability_name, type, uses, hitrate, value)
    VALUES ('debaf730-cb24-4a75-861d-b144a426968f', 'Water Gun', 'Water', 25, 100, 40);
    

    INSERT INTO abilities_table (ability_id, ability_name, type, uses, hitrate, value)
    VALUES ('b6842384-4b76-4ca9-b49e-ef7c3a6a10ed', 'Thunderbolt', 'Electric', 15, 100, 90);
    

    INSERT INTO abilities_table (ability_id, ability_name, type, uses, hitrate, value)
    VALUES ('af429222-27d5-4771-abae-46d76f234ab4', 'Quick Attack', 'Normal', 30, 100, 40);
    

    INSERT INTO abilities_table (ability_id, ability_name, type, uses, hitrate, value)
    VALUES ('6404ac01-7d40-4b9a-9e3c-f0e6ec78f6c2', 'Flamethrower', 'Fire', 15, 100, 90);
    

    INSERT INTO abilities_table (ability_id, ability_name, type, uses, hitrate, value)
    VALUES ('0d6bfbc8-d17e-4c66-a8a1-06d65475f00f', 'Hydro Pump', 'Water', 5, 80, 110);
    

    INSERT INTO abilities_table (ability_id, ability_name, type, uses, hitrate, value)
    VALUES ('c880e241-5296-4286-885c-d59819248be3', 'Razor Leaf', 'Grass', 25, 95, 55);
    

    INSERT INTO abilities_table (ability_id, ability_name, type, uses, hitrate, value)
    VALUES ('b4dcff93-d520-4822-9338-fb15616e5b90', 'Ice Beam', 'Ice', 10, 100, 90);
    

    INSERT INTO abilities_table (ability_id, ability_name, type, uses, hitrate, value)
    VALUES ('5a3c4072-1779-4609-bca8-95ffb5a3d8bd', 'Earthquake', 'Ground', 10, 100, 100);
    

    INSERT INTO abilities_table (ability_id, ability_name, type, uses, hitrate, value)
    VALUES ('8aca389f-4a70-4287-a318-6c42ee5dbca5', 'Psychic', 'Psychic', 10, 100, 90);

    
    INSERT INTO user_authentication_table (trainer_id, created_at, username, password, email)
    VALUES ('b0fedc38-990f-4ff1-befb-11fca4357462', now(), 'ash_ketchum', 'password123', 'ash_ketchum@example.com');
    

    INSERT INTO user_authentication_table (trainer_id, created_at, username, password, email)
    VALUES ('6dfb5c6c-8008-4df1-8642-c284e0007a3a', now(), 'misty_wtr', 'password123', 'misty_wtr@example.com');
    

    INSERT INTO user_authentication_table (trainer_id, created_at, username, password, email)
    VALUES ('e9c30ce7-f62e-464d-ba22-39b936172b57', now(), 'brock_boulder', 'password123', 'brock_boulder@example.com');
    

    INSERT INTO user_authentication_table (trainer_id, created_at, username, password, email)
    VALUES ('1dc1642c-3977-46cb-90ed-7b286dc1806e', now(), 'gary_oak', 'password123', 'gary_oak@example.com');
    

    INSERT INTO user_authentication_table (trainer_id, created_at, username, password, email)
    VALUES ('05ceec13-64d5-4345-8df9-84ca4b135a79', now(), 'may_travel', 'password123', 'may_travel@example.com');
    

    INSERT INTO trainer_table (trainer_id, created_at, sex, username, wins, losses, experience_points, level, favorite_pokemon, pokemon_slot_1, pokemon_slot_2, pokemon_slot_3, pokemon_slot_4, pokemon_slot_5, pokemon_slot_6)
    VALUES ('b0fedc38-990f-4ff1-befb-11fca4357462', now(), 'Male', 'ash_ketchum', 10, 3, 176, 2, '158ff09f-4733-491c-bcb8-1a788420c2b8', '158ff09f-4733-491c-bcb8-1a788420c2b8', 'f2026ce7-c232-45c4-a92c-f53fac610809', null, null, null, null);
    

    INSERT INTO trainer_table (trainer_id, created_at, sex, username, wins, losses, experience_points, level, favorite_pokemon, pokemon_slot_1, pokemon_slot_2, pokemon_slot_3, pokemon_slot_4, pokemon_slot_5, pokemon_slot_6)
    VALUES ('6dfb5c6c-8008-4df1-8642-c284e0007a3a', now(), 'Male', 'misty_wtr', 4, 10, 860, 5, '6dbd4009-6d09-4dbd-9cf7-144491b75482', '6dbd4009-6d09-4dbd-9cf7-144491b75482', 'cbb2aeec-d5a6-478c-8660-707ba1de0533', null, null, null, null);
    

    INSERT INTO trainer_table (trainer_id, created_at, sex, username, wins, losses, experience_points, level, favorite_pokemon, pokemon_slot_1, pokemon_slot_2, pokemon_slot_3, pokemon_slot_4, pokemon_slot_5, pokemon_slot_6)
    VALUES ('e9c30ce7-f62e-464d-ba22-39b936172b57', now(), 'Male', 'brock_boulder', 1, 8, 955, 10, 'edd7c4b0-2215-41b2-b729-b0109281093a', '3e4c8fd4-7be5-4135-97c8-83d3c5b9ebcf', 'f568ec71-ef27-4f26-a9a4-c18ba1805f2f', 'edd7c4b0-2215-41b2-b729-b0109281093a', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'b2c3d4e5-f607-8901-bcde-f12345678901', 'c3d4e5f6-a708-9012-cdef-123456789012');
    

    INSERT INTO trainer_table (trainer_id, created_at, sex, username, wins, losses, experience_points, level, favorite_pokemon, pokemon_slot_1, pokemon_slot_2, pokemon_slot_3, pokemon_slot_4, pokemon_slot_5, pokemon_slot_6)
    VALUES ('1dc1642c-3977-46cb-90ed-7b286dc1806e', now(), 'Male', 'gary_oak', 5, 3, 306, 1, '7468d04d-def6-4867-b981-acb29312644b', 'aabf5d8b-3586-450d-b0eb-5f008cdfb92f', '7468d04d-def6-4867-b981-acb29312644b', '92ac6202-f5fc-45bd-88d6-53d4b5e9e757', '36ff591b-e9a3-4478-8bed-dcd00a41d65e', 'd4e5f607-a809-0123-de2a-234567890123', 'e5f6a708-b900-1234-e2ab-345678901234');
    

    INSERT INTO trainer_table (trainer_id, created_at, sex, username, wins, losses, experience_points, level, favorite_pokemon, pokemon_slot_1, pokemon_slot_2, pokemon_slot_3, pokemon_slot_4, pokemon_slot_5, pokemon_slot_6)
    VALUES ('05ceec13-64d5-4345-8df9-84ca4b135a79', now(), 'Female', 'may_travel', 1, 10, 661, 9, '72ce97c4-b39f-46ce-aef2-2b757b75405f', 'ba60ece1-94bd-47a2-a79e-e0ef92dc9897', '72ce97c4-b39f-46ce-aef2-2b757b75405f', '6f4c4ea2-ce62-461a-9561-2a115ee20ff2', 'c5c3dc63-cd98-4c23-902b-8baa032f0a9c', null, null);
    

    

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('5d126224-c494-41a4-886f-04e49cb252ad', now(), 'Battle Strategies', '#FF0000', 'b0fedc38-990f-4ff1-befb-11fca4357462');
        

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('de65badc-d4e9-4457-9fde-e3dde76982e8', now(), 'Battle Strategies', '#FF8C00', 'b0fedc38-990f-4ff1-befb-11fca4357462');
        

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('c2a16582-545a-44bd-96bc-4befe168b881', now(), 'Healing Schedule', '#32CD32', 'b0fedc38-990f-4ff1-befb-11fca4357462');
        

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('cc7ae17b-09e6-436b-bbf8-e6b99b4a0606', now(), 'Captured Pokémon', '#1E90FF', '6dfb5c6c-8008-4df1-8642-c284e0007a3a');
        

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('27b00535-3f72-40e2-8c41-46f7c86ad6ad', now(), 'Training Notes', '#8A2BE2', '6dfb5c6c-8008-4df1-8642-c284e0007a3a');
        

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('3f01a540-b4b0-4316-8b3c-44800daa5601', now(), 'Battle Strategies', '#FFD700', '6dfb5c6c-8008-4df1-8642-c284e0007a3a');
        

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('a3bbcf94-2777-40d2-bb72-58da1716e7f6', now(), 'Captured Pokémon', '#8B4513', 'e9c30ce7-f62e-464d-ba22-39b936172b57');
        

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('c98773cd-242e-4f83-951e-dcca63c4a5ad', now(), 'Battle Strategies', '#708090', 'e9c30ce7-f62e-464d-ba22-39b936172b57');
        

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('31800197-5541-4a70-82af-81993714f37a', now(), 'Training Notes', '#FF69B4', '1dc1642c-3977-46cb-90ed-7b286dc1806e');
        

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('970020ce-0bfa-4899-9efa-922977a6ea80', now(), 'Healing Schedule', '#00FFFF', '1dc1642c-3977-46cb-90ed-7b286dc1806e');
        

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('a9e88116-ef4b-4680-8818-d0f94cdde3c2', now(), 'Captured Pokémon', '#008080', '05ceec13-64d5-4345-8df9-84ca4b135a79');
        

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('df5b25ad-7976-4f47-9fce-212755a087b7', now(), 'Captured Pokémon', '#32FF32', '05ceec13-64d5-4345-8df9-84ca4b135a79');
        

        INSERT INTO folder_table (folder_id, created_at, folder_name, color, trainer_id)
        VALUES ('e0c610ab-f6d5-4981-9981-052fe106d96f', now(), 'Healing Schedule', '#4B0082', '05ceec13-64d5-4345-8df9-84ca4b135a79');
        

        INSERT INTO threads_table (thread_id, created_at, trainer_id, thread_name)
        VALUES ('6d0ec49b-c082-449c-b3e8-1dc6dc07ed39', now(), 'b0fedc38-990f-4ff1-befb-11fca4357462', 'Gym Training Progress');
        

        INSERT INTO threads_table (thread_id, created_at, trainer_id, thread_name)
        VALUES ('3001c9be-faad-42a0-93a2-04556e2b76a4', now(), 'b0fedc38-990f-4ff1-befb-11fca4357462', 'Pokemon Center Visits');
        

        INSERT INTO threads_table (thread_id, created_at, trainer_id, thread_name)
        VALUES ('61634a66-61d0-4f94-acdf-efbf86bd93e5', now(), '6dfb5c6c-8008-4df1-8642-c284e0007a3a', 'Water Pokemon Evolution');
        

        INSERT INTO threads_table (thread_id, created_at, trainer_id, thread_name)
        VALUES ('3f6f1c0e-d60c-4937-a263-40c413aa642e', now(), 'e9c30ce7-f62e-464d-ba22-39b936172b57', 'Rock Gym Management');
        

        INSERT INTO threads_table (thread_id, created_at, trainer_id, thread_name)
        VALUES ('f5d04179-8f28-4e73-a6fb-61d012debff9', now(), 'e9c30ce7-f62e-464d-ba22-39b936172b57', 'Gym Maintenance Tasks');
        

        INSERT INTO threads_table (thread_id, created_at, trainer_id, thread_name)
        VALUES ('8952db61-1f03-4e0c-9a08-b16b13cc9fd2', now(), '1dc1642c-3977-46cb-90ed-7b286dc1806e', 'Tournament Preparation');
        

        INSERT INTO threads_table (thread_id, created_at, trainer_id, thread_name)
        VALUES ('1517efa4-6490-4855-9f1e-ba722479c7af', now(), '1dc1642c-3977-46cb-90ed-7b286dc1806e', 'Wild Area Exploration');
        

        INSERT INTO threads_table (thread_id, created_at, trainer_id, thread_name)
        VALUES ('55d50e2c-f864-4f89-b7a1-833d0fefcc57', now(), '05ceec13-64d5-4345-8df9-84ca4b135a79', 'Adventure Planning');
        

        INSERT INTO threads_table (thread_id, created_at, trainer_id, thread_name)
        VALUES ('31189f7b-fc51-4e27-a9a0-b7b50e85ddbb', now(), '05ceec13-64d5-4345-8df9-84ca4b135a79', 'Daily Pokemon Care');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('a18ccc16-f95e-4ef5-81df-97aa8aff694e', now(), '2025-07-17 14:30:00', '2025-07-16 09:00:00', null, true, true, 'Remember to complete this task.', 'Visit PokéCenter', 'b0fedc38-990f-4ff1-befb-11fca4357462', '3001c9be-faad-42a0-93a2-04556e2b76a4', '5d126224-c494-41a4-886f-04e49cb252ad');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('840cdefe-e546-4ca4-b719-26b688e5422f', now(), '2025-07-18 16:00:00', '2025-07-17 08:30:00', null, true, true, 'Remember to complete this task.', 'Train at the gym', 'b0fedc38-990f-4ff1-befb-11fca4357462', '6d0ec49b-c082-449c-b3e8-1dc6dc07ed39', 'c2a16582-545a-44bd-96bc-4befe168b881');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('2235c294-f50b-4716-8c48-767e4628dc2b', now(), '2025-07-16 20:00:00', '2025-07-15 13:15:00', null, true, true, 'Remember to complete this task.', 'Evolve Pokémon', '6dfb5c6c-8008-4df1-8642-c284e0007a3a', '61634a66-61d0-4f94-acdf-efbf86bd93e5', '3f01a540-b4b0-4316-8b3c-44800daa5601');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('c2d8ae02-d73c-4880-9269-b5d7c3c58810', now(), '2025-07-17 11:45:00', '2025-07-16 10:30:00', null, false, false, 'Remember to complete this task.', 'Visit PokéCenter', '6dfb5c6c-8008-4df1-8642-c284e0007a3a', '61634a66-61d0-4f94-acdf-efbf86bd93e5', '3f01a540-b4b0-4316-8b3c-44800daa5601');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('ebeadd16-6917-41cb-a5d0-b409266988e1', now(), '2025-07-18 22:00:00', '2025-07-17 15:00:00', null, true, false, 'Remember to complete this task.', 'Evolve Pokémon', '6dfb5c6c-8008-4df1-8642-c284e0007a3a', '61634a66-61d0-4f94-acdf-efbf86bd93e5', '27b00535-3f72-40e2-8c41-46f7c86ad6ad');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('1632e1c0-a4ed-478d-95d7-e2ec4b1799ad', now(), '2025-07-17 19:30:00', '2025-07-16 07:00:00', null, true, true, 'Remember to complete this task.', 'Evolve Pokémon', 'e9c30ce7-f62e-464d-ba22-39b936172b57', '3f6f1c0e-d60c-4937-a263-40c413aa642e', 'c98773cd-242e-4f83-951e-dcca63c4a5ad');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('0b770a19-08fa-49e0-853a-fa18908cb1f0', now(), '2025-07-16 18:45:00', '2025-07-15 14:20:00', null, false, true, 'Remember to complete this task.', 'Train at the gym', 'e9c30ce7-f62e-464d-ba22-39b936172b57', '3f6f1c0e-d60c-4937-a263-40c413aa642e', 'a3bbcf94-2777-40d2-bb72-58da1716e7f6');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('da2258ef-8fa3-4e03-bd12-74ea5d7609ff', now(), '2025-07-18 12:00:00', '2025-07-17 06:30:00', null, true, true, 'Remember to complete this task.', 'Scout wild area', 'e9c30ce7-f62e-464d-ba22-39b936172b57', '3f6f1c0e-d60c-4937-a263-40c413aa642e', 'c98773cd-242e-4f83-951e-dcca63c4a5ad');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('311be95c-0297-4ca8-b7c5-72042d12cd3f', now(), '2025-07-17 21:15:00', '2025-07-16 16:45:00', null, true, true, 'Remember to complete this task.', 'Train at the gym', 'e9c30ce7-f62e-464d-ba22-39b936172b57', '3f6f1c0e-d60c-4937-a263-40c413aa642e', 'a3bbcf94-2777-40d2-bb72-58da1716e7f6');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('a4a7fcca-fabd-4641-ad53-331c4c453cad', now(), '2025-07-16 15:30:00', '2025-07-15 11:00:00', null, true, true, 'Remember to complete this task.', 'Visit PokéCenter', '1dc1642c-3977-46cb-90ed-7b286dc1806e', '8952db61-1f03-4e0c-9a08-b16b13cc9fd2', '31800197-5541-4a70-82af-81993714f37a');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('6f82f63e-b9e6-4e35-80ab-26c39db2cf7d', now(), '2025-07-17 13:20:00', '2025-07-16 12:00:00', null, false, false, 'Remember to complete this task.', 'Train at the gym', '1dc1642c-3977-46cb-90ed-7b286dc1806e', '1517efa4-6490-4855-9f1e-ba722479c7af', '31800197-5541-4a70-82af-81993714f37a');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('61385f87-3ad5-4902-af22-e8fd42b92c89', now(), '2025-07-18 20:45:00', '2025-07-17 09:15:00', null, true, false, 'Remember to complete this task.', 'Prepare for tournament', '1dc1642c-3977-46cb-90ed-7b286dc1806e', '8952db61-1f03-4e0c-9a08-b16b13cc9fd2', '31800197-5541-4a70-82af-81993714f37a');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('15c0593c-031f-44f7-931a-7d1d7ae715ce', now(), '2025-07-16 17:00:00', '2025-07-15 08:45:00', null, false, false, 'Remember to complete this task.', 'Scout wild area', '1dc1642c-3977-46cb-90ed-7b286dc1806e', '1517efa4-6490-4855-9f1e-ba722479c7af', '970020ce-0bfa-4899-9efa-922977a6ea80');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('20fe66f8-54be-4e78-a86e-22e13836648c', now(), '2025-07-17 14:30:00', '2025-07-16 11:15:00', null, true, false, 'Remember to complete this task.', 'Scout wild area', '05ceec13-64d5-4345-8df9-84ca4b135a79', '55d50e2c-f864-4f89-b7a1-833d0fefcc57', 'a9e88116-ef4b-4680-8818-d0f94cdde3c2');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('c7d4ed44-c396-4b1f-893f-197223632ffe', now(), '2025-07-18 10:00:00', '2025-07-17 07:30:00', null, false, true, 'Remember to complete this task.', 'Visit PokéCenter', '05ceec13-64d5-4345-8df9-84ca4b135a79', '55d50e2c-f864-4f89-b7a1-833d0fefcc57', 'e0c610ab-f6d5-4981-9981-052fe106d96f');
        

        -- Additional tasks for brock_boulder
        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('b1f2a3b4-c5d6-7e8f-9012-345678901234', now(), '2025-07-16 14:30:00', '2025-07-16 10:00:00', null, false, true, 'Check rock-type Pokemon health status.', 'Examine Geodude for injuries', 'e9c30ce7-f62e-464d-ba22-39b936172b57', '3f6f1c0e-d60c-4937-a263-40c413aa642e', 'a3bbcf94-2777-40d2-bb72-58da1716e7f6');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('c2e3d4f5-a6b7-8c9d-0e1f-456789012345', now(), '2025-07-17 16:45:00', '2025-07-17 14:15:00', null, false, false, 'Prepare nutritious meal for rock Pokemon.', 'Cook special rock Pokemon food', 'e9c30ce7-f62e-464d-ba22-39b936172b57', null, null);
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('d3f4e5a6-b7c8-9d0e-1f2a-567890123456', now(), '2025-07-18 11:30:00', '2025-07-18 09:45:00', null, false, true, 'Schedule gym maintenance tasks.', 'Clean gym equipment and rocks', 'e9c30ce7-f62e-464d-ba22-39b936172b57', 'f5d04179-8f28-4e73-a6fb-61d012debff9', 'c98773cd-242e-4f83-951e-dcca63c4a5ad');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('e4a5b6c7-d8e9-0f1a-2b3c-678901234567', now(), '2025-07-16 18:00:00', '2025-07-16 15:30:00', null, false, false, 'Study Pokemon breeding patterns.', 'Research Onix mating habits', 'e9c30ce7-f62e-464d-ba22-39b936172b57', null, 'a3bbcf94-2777-40d2-bb72-58da1716e7f6');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('f5b6c7d8-e9f0-1a2b-3c4d-789012345678', now(), '2025-07-17 20:30:00', '2025-07-17 19:00:00', null, false, true, 'Prepare for upcoming gym battles.', 'Practice rock-type battle strategies', 'e9c30ce7-f62e-464d-ba22-39b936172b57', '3f6f1c0e-d60c-4937-a263-40c413aa642e', null);
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('a6c7d8e9-f0a1-2b3c-4d5e-890123456789', now(), '2025-07-18 13:15:00', '2025-07-18 12:00:00', null, false, false, 'Complete daily Pokemon care routine.', 'Groom and feed all Pokemon', 'e9c30ce7-f62e-464d-ba22-39b936172b57', null, null);
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('b7d8e9f0-a1b2-3c4d-5e6f-901234567890', now(), '2025-07-16 22:00:00', '2025-07-16 21:00:00', null, false, true, 'Review gym challenger applications.', 'Process new trainer requests', 'e9c30ce7-f62e-464d-ba22-39b936172b57', 'f5d04179-8f28-4e73-a6fb-61d012debff9', 'c98773cd-242e-4f83-951e-dcca63c4a5ad');
        

        INSERT INTO task_table (task_id, created_at, end_date, start_date, date_completed, is_all_day, high_priority, task_notes, task_text, trainer_id, thread_id, folder_id)
        VALUES ('c8e9f0a1-b2c3-4d5e-6f7a-012345678901', now(), '2025-07-17 10:45:00', '2025-07-17 08:30:00', null, false, false, 'Organize Pokemon medicine supplies.', 'Sort and inventory healing items', 'e9c30ce7-f62e-464d-ba22-39b936172b57', null, 'a3bbcf94-2777-40d2-bb72-58da1716e7f6');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('158ff09f-4733-491c-bcb8-1a788420c2b8', now(), 'Bulbasaur', 'Fang', 'Bulbasaur', 3, 91, 'b0fedc38-990f-4ff1-befb-11fca4357462', 16, 38, 'debaf730-cb24-4a75-861d-b144a426968f', 'b6842384-4b76-4ca9-b49e-ef7c3a6a10ed');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('f2026ce7-c232-45c4-a92c-f53fac610809', now(), 'Charmander', 'Leafy', 'Charmander', 4, 69, 'b0fedc38-990f-4ff1-befb-11fca4357462', 19, 89, 'cca84005-5a30-4e0d-a6df-1a8fa61654ad', '8c4cfe4d-479f-4fb7-9403-6fc2a0bd0520');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('cbb2aeec-d5a6-478c-8660-707ba1de0533', now(), 'Bulbasaur', 'Drip', 'Bulbasaur', 2, 111, '6dfb5c6c-8008-4df1-8642-c284e0007a3a', 15, 27, '0d6bfbc8-d17e-4c66-a8a1-06d65475f00f', 'af429222-27d5-4771-abae-46d76f234ab4');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('6dbd4009-6d09-4dbd-9cf7-144491b75482', now(), 'Squirtle', 'Fang', 'Squirtle', 3, 189, '6dfb5c6c-8008-4df1-8642-c284e0007a3a', 28, 99, '5a3c4072-1779-4609-bca8-95ffb5a3d8bd', 'c880e241-5296-4286-885c-d59819248be3');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('3e4c8fd4-7be5-4135-97c8-83d3c5b9ebcf', now(), 'Bulbasaur', 'Bolt', 'Bulbasaur', 4, 100, 'e9c30ce7-f62e-464d-ba22-39b936172b57', 26, 32, 'cca84005-5a30-4e0d-a6df-1a8fa61654ad', '6404ac01-7d40-4b9a-9e3c-f0e6ec78f6c2');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('f568ec71-ef27-4f26-a9a4-c18ba1805f2f', now(), 'Charmander', 'Fang', 'Charmander', 3, 91, 'e9c30ce7-f62e-464d-ba22-39b936172b57', 19, 85, '8c4cfe4d-479f-4fb7-9403-6fc2a0bd0520', 'b6842384-4b76-4ca9-b49e-ef7c3a6a10ed');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('edd7c4b0-2215-41b2-b729-b0109281093a', now(), 'Squirtle', 'Shellshock', 'Squirtle', 5, 79, 'e9c30ce7-f62e-464d-ba22-39b936172b57', 10, 63, '5a3c4072-1779-4609-bca8-95ffb5a3d8bd', '8aca389f-4a70-4287-a318-6c42ee5dbca5');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('aabf5d8b-3586-450d-b0eb-5f008cdfb92f', now(), 'Squirtle', 'Blaze', 'Squirtle', 1, 99, '1dc1642c-3977-46cb-90ed-7b286dc1806e', 20, 72, 'cca84005-5a30-4e0d-a6df-1a8fa61654ad', 'af429222-27d5-4771-abae-46d76f234ab4');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('7468d04d-def6-4867-b981-acb29312644b', now(), 'Squirtle', 'Shellshock', 'Squirtle', 4, 51, '1dc1642c-3977-46cb-90ed-7b286dc1806e', 23, 67, 'b6842384-4b76-4ca9-b49e-ef7c3a6a10ed', '8aca389f-4a70-4287-a318-6c42ee5dbca5');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('92ac6202-f5fc-45bd-88d6-53d4b5e9e757', now(), 'Squirtle', 'Leafy', 'Squirtle', 4, 137, '1dc1642c-3977-46cb-90ed-7b286dc1806e', 24, 29, '09dfc037-616a-4274-8a9a-e26f03229738', '8aca389f-4a70-4287-a318-6c42ee5dbca5');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('36ff591b-e9a3-4478-8bed-dcd00a41d65e', now(), 'Squirtle', 'Shellshock', 'Squirtle', 4, 69, '1dc1642c-3977-46cb-90ed-7b286dc1806e', 19, 33, '8aca389f-4a70-4287-a318-6c42ee5dbca5', '6404ac01-7d40-4b9a-9e3c-f0e6ec78f6c2');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('ba60ece1-94bd-47a2-a79e-e0ef92dc9897', now(), 'Bulbasaur', 'Buddy', 'Bulbasaur', 4, 68, '05ceec13-64d5-4345-8df9-84ca4b135a79', 10, 31, '09dfc037-616a-4274-8a9a-e26f03229738', '8c4cfe4d-479f-4fb7-9403-6fc2a0bd0520');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('72ce97c4-b39f-46ce-aef2-2b757b75405f', now(), 'Charmander', 'Blaze', 'Charmander', 5, 62, '05ceec13-64d5-4345-8df9-84ca4b135a79', 26, 63, 'b6842384-4b76-4ca9-b49e-ef7c3a6a10ed', '0d6bfbc8-d17e-4c66-a8a1-06d65475f00f');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('6f4c4ea2-ce62-461a-9561-2a115ee20ff2', now(), 'Charmander', 'Buddy', 'Charmander', 4, 141, '05ceec13-64d5-4345-8df9-84ca4b135a79', 21, 46, '09dfc037-616a-4274-8a9a-e26f03229738', 'af429222-27d5-4771-abae-46d76f234ab4');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('c5c3dc63-cd98-4c23-902b-8baa032f0a9c', now(), 'Charmander', 'Torch', 'Charmander', 3, 153, '05ceec13-64d5-4345-8df9-84ca4b135a79', 24, 54, 'af429222-27d5-4771-abae-46d76f234ab4', '6404ac01-7d40-4b9a-9e3c-f0e6ec78f6c2');
        

        -- Additional Pokemon for brock_boulder to make 6 total
        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', now(), 'Pikachu', 'Sparky', 'Electric', 5, 95, 'e9c30ce7-f62e-464d-ba22-39b936172b57', 22, 45, 'b6842384-4b76-4ca9-b49e-ef7c3a6a10ed', 'af429222-27d5-4771-abae-46d76f234ab4');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('b2c3d4e5-f607-8901-bcde-f12345678901', now(), 'Geodude', 'Rocky', 'Rock', 4, 88, 'e9c30ce7-f62e-464d-ba22-39b936172b57', 25, 55, '5a3c4072-1779-4609-bca8-95ffb5a3d8bd', 'cca84005-5a30-4e0d-a6df-1a8fa61654ad');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('c3d4e5f6-a708-9012-cdef-123456789012', now(), 'Onix', 'Crusher', 'Rock', 6, 120, 'e9c30ce7-f62e-464d-ba22-39b936172b57', 30, 70, '5a3c4072-1779-4609-bca8-95ffb5a3d8bd', 'b4dcff93-d520-4822-9338-fb15616e5b90');
        

        -- Additional Pokemon for gary_oak to make 6 total
        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('d4e5f607-a809-0123-de2a-234567890123', now(), 'Wartortle', 'Aqua', 'Water', 5, 110, '1dc1642c-3977-46cb-90ed-7b286dc1806e', 27, 58, '0d6bfbc8-d17e-4c66-a8a1-06d65475f00f', 'debaf730-cb24-4a75-861d-b144a426968f');
        

        INSERT INTO pokemon_table (pokemon_id, date_caught, pokemon_name, nickname, type, level, experience_points, trainer_id, attack, health, ability1, ability2)
        VALUES ('e5f6a708-b900-1234-e2ab-345678901234', now(), 'Nidoking', 'King', 'Poison', 7, 145, '1dc1642c-3977-46cb-90ed-7b286dc1806e', 32, 75, '8aca389f-4a70-4287-a318-6c42ee5dbca5', '5a3c4072-1779-4609-bca8-95ffb5a3d8bd');
        