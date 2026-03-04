"""RAG Engine for UCIC campus information retrieval.

Uses TF-IDF + cosine similarity with keyword boosting for
fast, lightweight document retrieval without external vector DBs.
"""

import json
import os
import re
from typing import List, Dict, Optional

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

from config import DATASET_PATH, RAG_TOP_K


class RAGEngine:
    """Retrieval-Augmented Generation engine using TF-IDF similarity."""

    def __init__(self, dataset_path: Optional[str] = None):
        self.dataset_path = dataset_path or DATASET_PATH
        self.documents: List[Dict] = []
        self.vectorizer: Optional[TfidfVectorizer] = None
        self.tfidf_matrix = None
        self._load_dataset()
        self._build_index()

    def _load_dataset(self):
        """Load documents from the JSON dataset file."""
        if not os.path.exists(self.dataset_path):
            print(f"[RAG] WARNING: Dataset not found at {self.dataset_path}")
            self.documents = []
            return

        with open(self.dataset_path, "r", encoding="utf-8") as f:
            self.documents = json.load(f)

        print(f"[RAG] Loaded {len(self.documents)} documents from dataset")

    def _build_index(self):
        """Build TF-IDF index from documents."""
        if not self.documents:
            print("[RAG] No documents to index")
            return

        # Combine title, content, and keywords for each document
        corpus = []
        for doc in self.documents:
            text_parts = [
                doc.get("title", ""),
                doc.get("content", ""),
                " ".join(doc.get("keywords", [])),
                doc.get("category", ""),
            ]
            corpus.append(" ".join(text_parts))

        self.vectorizer = TfidfVectorizer(
            lowercase=True,
            max_features=5000,
            ngram_range=(1, 2),  # Unigrams and bigrams
            stop_words=None,     # Keep Indonesian words
        )
        self.tfidf_matrix = self.vectorizer.fit_transform(corpus)
        print(f"[RAG] Built TF-IDF index with {self.tfidf_matrix.shape[1]} features")

    def _keyword_boost(self, query: str, doc: Dict, base_score: float) -> float:
        """Boost score if query matches document keywords directly."""
        query_lower = query.lower().strip()
        keywords = [kw.lower() for kw in doc.get("keywords", [])]

        boost = 0.0
        for kw in keywords:
            if kw in query_lower:
                boost += 0.3  # Each matching keyword adds 0.3
            elif query_lower in kw:
                boost += 0.15  # Partial match

        return min(base_score + boost, 1.0)

    def search(self, query: str, top_k: Optional[int] = None) -> List[Dict]:
        """Search for relevant documents given a query.

        Args:
            query: The user's question/query string
            top_k: Number of top results to return (default from config)

        Returns:
            List of dicts with 'id', 'title', 'content', 'score'
        """
        if not self.documents or self.vectorizer is None:
            return []

        k = top_k or RAG_TOP_K

        # Transform query using the fitted vectorizer
        query_vec = self.vectorizer.transform([query])
        similarities = cosine_similarity(query_vec, self.tfidf_matrix)[0]

        # Apply keyword boosting
        boosted_scores = []
        for i, (score, doc) in enumerate(zip(similarities, self.documents)):
            boosted = self._keyword_boost(query, doc, float(score))
            boosted_scores.append((i, boosted))

        # Sort by boosted score descending
        boosted_scores.sort(key=lambda x: x[1], reverse=True)

        # Return top_k results with score > threshold
        results = []
        for idx, score in boosted_scores[:k]:
            if score < 0.05:  # Minimum relevance threshold
                continue
            doc = self.documents[idx]
            results.append({
                "id": doc.get("id", ""),
                "title": doc.get("title", ""),
                "content": doc.get("content", ""),
                "category": doc.get("category", ""),
                "score": round(score, 4),
            })

        return results

    def get_context(self, query: str, top_k: Optional[int] = None) -> str:
        """Get formatted context string from RAG search results.

        This is the main method used by the agent to get context for the LLM.
        """
        results = self.search(query, top_k)

        if not results:
            return ""

        context_parts = []
        for r in results:
            context_parts.append(f"## {r['title']}\n{r['content']}")

        return "\n\n".join(context_parts)

    def get_stats(self) -> Dict:
        """Return statistics about the RAG engine."""
        return {
            "total_documents": len(self.documents),
            "index_features": self.tfidf_matrix.shape[1] if self.tfidf_matrix is not None else 0,
            "categories": list(set(doc.get("category", "") for doc in self.documents)),
        }
