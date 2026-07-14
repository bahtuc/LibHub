// src/components/Icon.jsx
// Tiny dependency-free icon set (stroke-based, 1.5px) so the homepage
// doesn't require an icon library. Swap for lucide-react/heroicons any time.

const paths = {
  "book-open": "M12 6.5c-1.8-1.3-4.2-2-7-2v13c2.8 0 5.2.7 7 2 1.8-1.3 4.2-2 7-2V4.5c-2.8 0-5.2.7-7 2Z M12 6.5v13",
  flask: "M9 3h6 M10 3v6.2L5.5 18a1.5 1.5 0 0 0 1.3 2.2h10.4a1.5 1.5 0 0 0 1.3-2.2L14 9.2V3",
  compass: "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z M14.5 9.5 13 13l-3.5 1.5L11 11l3.5-1.5Z",
  briefcase: "M3 8.5A1.5 1.5 0 0 1 4.5 7h15A1.5 1.5 0 0 1 21 8.5V18a1.5 1.5 0 0 1-1.5 1.5h-15A1.5 1.5 0 0 1 3 18V8.5Z M8 7V5.5A1.5 1.5 0 0 1 9.5 4h5A1.5 1.5 0 0 1 16 5.5V7 M3 12h18",
  star: "M12 3.5l2.6 5.4 5.9.8-4.3 4.2 1 5.9-5.2-2.8-5.2 2.8 1-5.9-4.3-4.2 5.9-.8Z",
  landmark: "M4 21h16 M5 21V10 M19 21V10 M3 10l9-6 9 6 M9 21v-7 M15 21v-7",
  users: "M8.5 12.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7Z M2.5 20c.7-3.4 3.1-5.3 6-5.3s5.3 1.9 6 5.3 M16.5 8a3 3 0 1 1 0 6 M17 14.3c2.6.4 4.5 2.2 5 5",
  layers: "m12 3 9 5-9 5-9-5 9-5Z M3 13l9 5 9-5 M3 17l9 5 9-5",
  "check-circle": "M21 11.5A9.5 9.5 0 1 1 12 2c1.8 0 3.5.5 5 1.4 M9 12l2 2 6-7",
  search: "M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16Z M21 21l-4.3-4.3",
  arrow: "M4.5 12h15 M13.5 5.5 20 12l-6.5 6.5",
  "map-pin": "M20 10.5c0 5.5-8 11.5-8 11.5s-8-6-8-11.5a8 8 0 1 1 16 0Z M12 13a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5Z",
  phone: "M4.5 4h3.6l1.4 4.8-2.3 1.6a12 12 0 0 0 6.4 6.4l1.6-2.3 4.8 1.4v3.6c0 1-.8 1.5-1.7 1.4C10.4 20 4 13.6 3.1 5.7 3 4.8 3.6 4 4.5 4Z",
  mail: "M3.5 5.5h17v13h-17v-13Z M3.5 6l8.5 7 8.5-7",
  facebook: "M15 8.5h-2c-.6 0-1 .5-1 1.2V12h3l-.4 3H12v7h-3v-7H7v-3h2V9.2C9 6.9 10.5 5 13 5h2v3.5Z",
  instagram: "M4 8a4 4 0 0 1 4-4h8a4 4 0 0 1 4 4v8a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4V8Z M12 15.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7Z M16.7 7.3h.01",
  user: "M12 12.5a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z M4.5 20c1-4.3 3.8-6.5 7.5-6.5s6.5 2.2 7.5 6.5",
  lock: "M7 10V7.5a5 5 0 0 1 10 0V10 M5.5 10h13v10.5h-13V10Z M12 14.5v3",
  edit: "M4 20h4L18.5 9.5a2 2 0 0 0 0-2.8l-1.2-1.2a2 2 0 0 0-2.8 0L4 16v4Z M14.5 6.5l3 3",
  trash: "M4 7h16 M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2 M6.5 7l1 13a2 2 0 0 0 2 2h5a2 2 0 0 0 2-2l1-13 M10 11v6 M14 11v6",
  plus: "M12 5v14 M5 12h14",
  dashboard: "M4 4h7v7H4V4Z M13 4h7v4h-7V4Z M13 11h7v9h-7v-9Z M4 14h7v6H4v-6Z",
  x: "M6 6l12 12 M18 6 6 18",
};

export default function Icon({ name, size = 20, strokeWidth = 1.6, className = "" }) {
  const d = paths[name];
  if (!d) return null;
  return (
    <svg
      className={`lh-icon ${className}`}
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d={d} />
    </svg>
  );
}
