import Header from "./components/Header";
import Hero from "./components/Hero";
import QuickAccess from "./components/QuickAccess";
import FeaturedBooks from "./components/FeaturedBooks";
import Categories from "./components/Categories";
import StatsBand from "./components/StatsBand";
import Contact from "./components/Contact";
import Footer from "./components/Footer";
import "./styles/theme.css";

export default function Home() {
  return (
    <div className="lh-root">
      <Header />
      <Hero />
      <QuickAccess />
      <FeaturedBooks />
      <Categories />
      <StatsBand />
      <Contact />
      <Footer />
    </div>
  );
}