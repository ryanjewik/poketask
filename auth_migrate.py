from supabase import create_client, Client
import psycopg2

# === Step 1: Set Supabase and DB config ===
SUPABASE_URL = ""
SUPABASE_SERVICE_KEY = ""

DB_CONFIG = {
    "host": "",
    "port": 0,
    "dbname": "",
    "user": "",
    "password": ""
}

# === Step 2: Setup Supabase + DB clients ===
supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
conn = psycopg2.connect(**DB_CONFIG)
cursor = conn.cursor()

# === Step 3: Fetch legacy user identifiers ===
cursor.execute("SELECT trainer_id, email, password FROM user_authentication_table")
rows = cursor.fetchall()

mappings = []

# === Step 4: Create new Supabase users and capture new UIDs ===
for old_id, email, password in rows:
    try:
        result = supabase.auth.admin.create_user({
            "email": email,
            "password": password,
            "email_confirm": True
        })

        if result.user is None:
            print(f"❌ No UID returned for {email} — skipping")
            continue

        new_id = result.user.id
        print(f"\n✅ Created user: {email} → new id: {new_id}")
        mappings.append((old_id, new_id))

    except Exception as e:
        print(f"❌ Failed to create user {email}: {e}")

# === Step 5: Apply ID updates using original_trainer_id as join key ===
for old_id, new_id in mappings:
    try:
        # trainer_table
        cursor.execute("""
            UPDATE trainer_table
            SET trainer_id = %s
            WHERE original_trainer_id = %s
        """, (new_id, old_id))

        # related tables
        for table in ['pokemon_table', 'threads_table', 'folder_table', 'task_table']:
            cursor.execute(f"""
                UPDATE {table}
                SET trainer_id = %s
                WHERE original_trainer_id = %s
            """, (new_id, old_id))

        conn.commit()
        print(f"✅ Updated trainer_id from {old_id} → {new_id}")

    except Exception as e:
        conn.rollback()
        print(f"❌ Failed to update trainer_id {old_id}: {e}")

cursor.close()
conn.close()

print("\n📋 Summary of trainer_id updates:")
for old_id, new_id in mappings:
    print(f"  {old_id} → {new_id}")