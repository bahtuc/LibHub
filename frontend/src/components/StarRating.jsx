// src/components/StarRating.jsx
// Hiển thị / chọn đánh giá sao. interactive=true dùng cho form viết đánh giá.
import "../styles/StarRating.css";

const STAR_PATH =
  "M12 3.5l2.6 5.4 5.9.8-4.3 4.2 1 5.9-5.2-2.8-5.2 2.8 1-5.9-4.3-4.2 5.9-.8Z";

export default function StarRating({ value = 0, onChange, size = 18, interactive = false }) {
  return (
    <span className={`lh-stars ${interactive ? "is-interactive" : ""}`}>
      {[1, 2, 3, 4, 5].map((n) => {
        const filled = n <= Math.round(value);
        return interactive ? (
          <button
            key={n}
            type="button"
            className="lh-star"
            aria-label={`${n} sao`}
            onClick={() => onChange?.(n)}
          >
            <svg width={size} height={size} viewBox="0 0 24 24">
              <path
                d={STAR_PATH}
                fill={filled ? "currentColor" : "none"}
                stroke="currentColor"
                strokeWidth="1.5"
                strokeLinejoin="round"
              />
            </svg>
          </button>
        ) : (
          <span key={n} className="lh-star" aria-hidden="true">
            <svg width={size} height={size} viewBox="0 0 24 24">
              <path
                d={STAR_PATH}
                fill={filled ? "currentColor" : "none"}
                stroke="currentColor"
                strokeWidth="1.5"
                strokeLinejoin="round"
              />
            </svg>
          </span>
        );
      })}
    </span>
  );
}
