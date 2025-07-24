-- Step 1: Roll back trainer_table
UPDATE trainer_table
SET trainer_id = original_trainer_id
WHERE original_trainer_id IS NOT NULL;

-- Step 2: Roll back pokemon_table
UPDATE pokemon_table
SET trainer_id = original_trainer_id
WHERE original_trainer_id IS NOT NULL;

-- Step 3: Roll back threads_table
UPDATE threads_table
SET trainer_id = original_trainer_id
WHERE original_trainer_id IS NOT NULL;

-- Step 4: Roll back folder_table
UPDATE folder_table
SET trainer_id = original_trainer_id
WHERE original_trainer_id IS NOT NULL;
