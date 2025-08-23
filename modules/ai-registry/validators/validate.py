#!/usr/bin/env python3
import json, sys, glob, os
from jsonschema import Draft202012Validator

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
schema_path = os.path.join(ROOT, "schema", "ai-registry.schema.json")
examples_glob = os.path.join(ROOT, "examples", "*.json")

with open(schema_path, encoding="utf-8") as f:
    schema = json.load(f)

validator = Draft202012Validator(schema)
errors = []
for path in sorted(glob.glob(examples_glob)):
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    errs = sorted(validator.iter_errors(data), key=lambda e: (list(e.path), e.message))
    if errs:
        print(f"❌ {os.path.basename(path)} INVALID")
        for e in errs:
            where = ".".join(str(x) for x in e.path)
            where = "$" if not where else "$."+where
            errors.append(f"{os.path.basename(path)}: {e.message} at {where}")
    else:
        print(f"✅ {os.path.basename(path)} OK")

if errors:
    print("\nFailures:")
    for e in errors:
        print("-", e)
    sys.exit(1)
