import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { Link } from "react-router-dom";
import Icon from "./Icon";
import { askBookAdviser } from "../services/ChatService";
import "../styles/BookChatbot.css";

const WELCOME = { role: "assistant", text: "Chào bạn, mình là Libby. Hôm nay bạn muốn đọc một câu chuyện như thế nào?" };
const STARTERS = ["Một cuốn nhẹ nhàng để thư giãn", "Sách giúp tôi tập trung hơn", "Trinh thám có cú lật bất ngờ"];

export default function BookChatbot() {
  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState([WELCOME]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const endRef = useRef(null);
  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: "smooth", block: "nearest" });
  }, [messages, loading]);

  async function send(text = input) {
    const value = text.trim();
    if (!value || loading) return;
    const userMessage = { role: "user", text: value };
    const history = messages.slice(-8).map(({ role, text: content }) => ({ role, text: content }));
    setMessages((current) => [...current, userMessage]);
    setInput(""); setLoading(true);
    try {
      const answer = await askBookAdviser(value, history);
      setMessages((current) => [...current, { role: "assistant", text: answer.reply, books: answer.books || [] }]);
    } catch (error) {
      setMessages((current) => [...current, { role: "assistant", text: error.message, error: true }]);
    } finally { setLoading(false); }
  }

  function handleInputKeyDown(event) {
    if (event.key !== "Enter" || event.shiftKey || event.nativeEvent.isComposing) return;
    event.preventDefault();
    event.stopPropagation();
    void send();
  }

  const chatbot = <div className={`lh-chat ${open ? "is-open" : ""}`}>
    {open && <section className="lh-chat__panel" aria-label="Libby tư vấn sách">
      <header className="lh-chat__head"><span><Icon name="book-open" size={20} /></span><div><strong>Libby</strong><small>Thủ thư AI · Gemini</small></div><button type="button" onClick={() => setOpen(false)} aria-label="Đóng"><Icon name="x" size={18}/></button></header>
      <div className="lh-chat__messages">
        {messages.map((message, index) => <div className={`lh-chat__message is-${message.role} ${message.error ? "is-error" : ""}`} key={index}>
          <p>{message.text}</p>
          {message.books?.map((book) => <Link to={`/books/${book.bookId}`} className="lh-chat__book" key={book.bookId} onClick={() => setOpen(false)}>
            <span><Icon name="book-open" size={16}/></span><div><strong>{book.title}</strong><small>{book.reason}</small></div><Icon name="arrow" size={14}/>
          </Link>)}
        </div>)}
        {messages.length === 1 && <div className="lh-chat__starters">{STARTERS.map((item) => <button type="button" key={item} onClick={() => void send(item)}>{item}</button>)}</div>}
        {loading && <div className="lh-chat__typing"><i/><i/><i/></div>}<div ref={endRef}/>
      </div>
      <div className="lh-chat__form"><textarea rows="1" maxLength="1200" value={input} onChange={(event) => setInput(event.target.value)} onKeyDown={handleInputKeyDown} placeholder="Ví dụ: Tôi thích truyện buồn, nhịp chậm..."/><button type="button" onClick={() => void send()} disabled={loading || !input.trim()} aria-label="Gửi"><Icon name="arrow" size={18}/></button></div>
      <small className="lh-chat__note">Libby chỉ gợi ý sách hiện có trong LibHub.</small>
    </section>}
    <button type="button" className="lh-chat__toggle" onClick={() => setOpen((value) => !value)} aria-label={open ? "Đóng tư vấn sách" : "Mở tư vấn sách"}><Icon name={open ? "x" : "book-open"} size={22}/><span>Gợi ý sách</span></button>
  </div>;

  // Header uses backdrop-filter, which creates a containing block for fixed
  // descendants in some browsers. Rendering at body level keeps the chatbot
  // pinned to the viewport instead of the sticky header.
  return createPortal(chatbot, document.body);
}
