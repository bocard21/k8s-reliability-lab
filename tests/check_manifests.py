"""Check the deploy contract without connecting to a cluster."""
from pathlib import Path
import sys
import yaml

for name in sys.argv[1:]:
    docs = [x for x in yaml.safe_load_all(Path(name).read_text()) if x]
    keys = [(x["kind"], x["metadata"]["name"]) for x in docs]
    assert len(keys) == len(set(keys)), "Duplicate resource"
    services = {x["metadata"]["name"]: x for x in docs if x["kind"] == "Service"}
    deploys = {x["metadata"]["name"]: x for x in docs if x["kind"] == "Deployment"}
    assert "techsafe-postgres" in services and "techsafe-postgres" in deploys
    for service in services.values():
        selector = service["spec"]["selector"]
        assert any(all(d["spec"]["template"]["metadata"]["labels"].get(k) == v
                       for k, v in selector.items()) for d in deploys.values()), service
    for d in deploys.values():
        for c in d["spec"]["template"]["spec"]["containers"]:
            assert "readinessProbe" in c and "livenessProbe" in c
    print(f"Manifest contract passed: {name}")

for path in Path("k8s").rglob("*.yaml"):
    list(yaml.safe_load_all(path.read_text()))
print("Kubernetes YAML parsed successfully")
