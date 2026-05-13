"""
Import a cleaned retail customer dataset into PostgreSQL.

This script:
1. Automatically detects a CSV file in the project folder
2. Loads the dataset with pandas
3. Connects to PostgreSQL using environment variables
4. Imports all rows and columns into the public.customers table
5. Verifies the number of imported rows and columns

Required environment variables:
- POSTGRES_USER
- POSTGRES_PASSWORD
- POSTGRES_HOST
- POSTGRES_PORT
- POSTGRES_DB
"""

import os
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text


def get_csv_file(project_dir: Path) -> Path:
    """
    Return the first CSV file found in the project directory.
    Raises an error if no CSV file is found.
    """
    csv_files = list(project_dir.glob("*.csv"))

    if not csv_files:
        raise FileNotFoundError(
            "No CSV file found in the project folder. "
            "Please add the dataset CSV file before running this script."
        )

    return csv_files[0]


def create_postgres_engine():
    """
    Create a PostgreSQL SQLAlchemy engine using environment variables.
    """
    username = os.getenv("POSTGRES_USER", "postgres")
    password = os.getenv("POSTGRES_PASSWORD")
    host = os.getenv("POSTGRES_HOST", "localhost")
    port = os.getenv("POSTGRES_PORT", "5432")
    database = os.getenv("POSTGRES_DB", "postgres")

    if not password:
        raise ValueError(
            "POSTGRES_PASSWORD environment variable is missing. "
            "Please set it before running this script."
        )

    connection_url = (
        f"postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}"
    )

    return create_engine(connection_url)


def import_dataframe_to_postgres(
    data: pd.DataFrame,
    engine,
    table_name: str = "customers",
    schema_name: str = "public"
) -> None:
    """
    Import a pandas DataFrame into PostgreSQL.
    Existing table is replaced to keep the import reproducible.
    """
    data.to_sql(
        name=table_name,
        con=engine,
        schema=schema_name,
        if_exists="replace",
        index=False,
        chunksize=1000,
        method="multi"
    )


def verify_import(engine, table_name: str = "customers", schema_name: str = "public"):
    """
    Verify the number of rows and columns imported into PostgreSQL.
    """
    with engine.connect() as conn:
        row_count = conn.execute(
            text(f'SELECT COUNT(*) FROM {schema_name}."{table_name}";')
        ).scalar()

        col_count = conn.execute(
            text("""
                SELECT COUNT(*)
                FROM information_schema.columns
                WHERE table_schema = :schema_name
                AND table_name = :table_name;
            """),
            {
                "schema_name": schema_name,
                "table_name": table_name
            }
        ).scalar()

    return row_count, col_count


def main():
    """
    Main execution function.
    """
    project_dir = Path(__file__).resolve().parent

    csv_path = get_csv_file(project_dir)
    data = pd.read_csv(csv_path)

    engine = create_postgres_engine()

    table_name = "customers"
    schema_name = "public"

    import_dataframe_to_postgres(
        data=data,
        engine=engine,
        table_name=table_name,
        schema_name=schema_name
    )

    row_count, col_count = verify_import(
        engine=engine,
        table_name=table_name,
        schema_name=schema_name
    )

    print("PostgreSQL import completed successfully.")
    print(f"CSV file used: {csv_path.name}")
    print(f"Target table: {schema_name}.{table_name}")
    print(f"Rows imported: {row_count}")
    print(f"Columns imported: {col_count}")


if __name__ == "__main__":
    main()