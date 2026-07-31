import { useCallback, useEffect, useState } from "react";

export default function useLoanViews(loader) {
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const refresh = useCallback(async () => {
    setLoading(true);
    try {
      const data = await loader();
      setTickets(Array.isArray(data) ? data : []);
      setError("");
    } catch (requestError) {
      setTickets([]);
      setError(requestError.message || "Không tải được dữ liệu mượn trả.");
    } finally {
      setLoading(false);
    }
  }, [loader]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  return { tickets, loading, error, refresh };
}
