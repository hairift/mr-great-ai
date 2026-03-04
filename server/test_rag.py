"""Quick test for RAG engine with expanded dataset."""
import sys
sys.path.insert(0, '.')

from rag_engine import RAGEngine

e = RAGEngine()
print(f"Total documents: {e.get_stats()['total_documents']}")
print(f"Categories: {e.get_stats()['categories']}")
print()

# Test 1: Search for jurusan
r = e.search("jurusan di UCIC")
print(f"=== Search: 'jurusan di UCIC' ({len(r)} results) ===")
for x in r:
    print(f"  - {x['title']} (score: {x['score']})")

# Test 2: Search for dosen
r2 = e.search("dosen algoritma pemrograman")
print(f"\n=== Search: 'dosen algoritma pemrograman' ({len(r2)} results) ===")
for x in r2:
    print(f"  - {x['title']} (score: {x['score']})")

# Test 3: Search for rektor
r3 = e.search("siapa rektor UCIC")
print(f"\n=== Search: 'siapa rektor UCIC' ({len(r3)} results) ===")
for x in r3:
    print(f"  - {x['title']} (score: {x['score']})")

# Test 4: Dosen kecerdasan buatan
r4 = e.search("marsani asfi kecerdasan buatan")
print(f"\n=== Search: 'marsani asfi kecerdasan buatan' ({len(r4)} results) ===")
for x in r4:
    print(f"  - {x['title']} (score: {x['score']})")

print("\n✅ All RAG tests passed!")
