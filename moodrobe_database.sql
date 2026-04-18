-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- USERS & AESTHETIC PROFILE AGGREGATE
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  selected_aesthetic_id UUID,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  preferences JSONB DEFAULT '{}',
  saved_aesthetics UUID [] DEFAULT ARRAY []::UUID [],
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE user_favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, product_id)
);
CREATE TABLE collections (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	name VARCHAR(255) NOT NULL,
	description TEXT,
	is_public BOOLEAN DEFAULT false,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
        
CREATE TABLE collection_items (                
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
	product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
	added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	UNIQUE(collection_id, product_id)
);
CREATE TABLE style_boards (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	name VARCHAR(255) NOT NULL,
	description TEXT,
	aesthetic_tags UUID[] DEFAULT ARRAY[]::UUID[],
	items JSONB NOT NULL DEFAULT '[]',
	is_public BOOLEAN DEFAULT false,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); 
-- AESTHETIC AGGREGATE
CREATE TABLE aesthetics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  theme_properties JSONB DEFAULT '{}',
  image_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- MERCHANT AGGREGATE
CREATE TABLE merchants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  business_details JSONB DEFAULT '{}',
  email VARCHAR(255) UNIQUE NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE merchant_staff (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID REFERENCES merchants(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(50) DEFAULT 'staff',
  permissions JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(merchant_id, user_id)
);
-- PRODUCT AGGREGATE
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID REFERENCES merchants(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(100),
  base_price DECIMAL(10, 2) NOT NULL,
  aesthetic_tags UUID [] DEFAULT ARRAY []::UUID [],
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE product_variants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  sku VARCHAR(100) UNIQUE NOT NULL,
  size VARCHAR(20),
  color VARCHAR(50),
  price DECIMAL(10, 2) NOT NULL,
  stock_quantity INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE product_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  url VARCHAR(500) NOT NULL,
  is_primary BOOLEAN DEFAULT false,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- CART AGGREGATE
CREATE TABLE carts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE cart_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cart_id UUID REFERENCES carts(id) ON DELETE CASCADE,
  product_variant_id UUID REFERENCES product_variants(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10, 2) NOT NULL,
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  product_name VARCHAR(255),
  currency VARCHAR(3) DEFAULT 'NGN',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  image_url VARCHAR(500),
  product_id UUID,
  variant_attributes JSONB,
  UNIQUE(cart_id, product_variant_id)
);
-- ORDER AGGREGATE
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  order_number VARCHAR(50) UNIQUE NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  subtotal DECIMAL(10, 2) NOT NULL,
  tax DECIMAL(10, 2) DEFAULT 0,
  discount DECIMAL(10, 2) DEFAULT 0,
  total_amount DECIMAL(10, 2) NOT NULL,
  shipping_address JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE order_lines (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_variant_id UUID REFERENCES product_variants(id),
  product_name VARCHAR(255) NOT NULL,
  variant_details JSONB,
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  line_total DECIMAL(10, 2) NOT NULL,
  image_url VARCHAR(500)
);
-- PAYMENT AGGREGATE
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  provider VARCHAR(50) NOT NULL,
  transaction_id VARCHAR(255),
  status VARCHAR(50) DEFAULT 'pending',
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  payment_method JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  refunded_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00
);
-- INVENTORY RESERVATIONS
CREATE TABLE inventory_reservations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_variant_id UUID REFERENCES product_variants(id),
  order_id UUID REFERENCES orders(id),
  quantity INTEGER NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- USER OUTFIT TABLE
CREATE TABLE user_outfits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  outfit_type VARCHAR(50) DEFAULT 'full', -- 'full', 'dress', 'casual', 'formal'
  items JSONB NOT NULL, -- {hat: productId, top: productId, bottom: productId, etc.}
  aesthetic_tags UUID[] DEFAULT ARRAY[]::UUID[],
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- INDEXES
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_merchant ON products(merchant_id);
CREATE INDEX idx_products_aesthetics ON products USING GIN(aesthetic_tags);
CREATE INDEX idx_product_variants_product ON product_variants(product_id);
CREATE INDEX idx_product_variants_sku ON product_variants(sku);
CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_lines_order ON order_lines(order_id);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_transaction ON payments(transaction_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_provider ON payments(provider);
CREATE INDEX idx_payments_created_at ON payments(created_at);
CREATE INDEX idx_user_outfits_user ON user_outfits(user_id);
CREATE INDEX idx_user_outfits_public ON user_outfits(is_public);
CREATE INDEX idx_user_outfits_type ON user_outfits(outfit_type);
CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_user_favorites_product_id ON user_favorites(product_id);
CREATE INDEX idx_collections_user_id ON collections(user_id);
CREATE INDEX idx_collection_items_collection_id ON collection_items(collection_id);
CREATE INDEX idx_collection_items_product_id ON collection_items(product_id);
CREATE INDEX idx_style_boards_user_id ON style_boards(user_id);
--TRIGGERS
-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_payments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_payments_timestamp
    BEFORE UPDATE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_payments_updated_at();
-- Aesthetics
INSERT INTO aesthetics (name, description, theme_properties)
VALUES (
    'minimalist',
    'Clean lines, neutral colors, simplicity. Less is more philosophy with focus on functionality and space.',
    '{"colors": ["white", "black", "gray", "beige"], "style": "modern", "mood": "calm", "keywords": ["clean", "simple", "minimal", "modern", "sleek"], "patterns": ["solid", "geometric"], "textures": ["smooth", "matte"]}'
  ),
  (
    'streetwear',
    'Urban, bold, casual. Influenced by hip-hop culture, skateboarding, and contemporary street fashion.',
    '{"colors": ["black", "red", "neon", "white"], "style": "edgy", "mood": "confident", "keywords": ["urban", "bold", "casual", "graphic", "sneakers"], "patterns": ["graphic", "camo", "abstract"], "textures": ["cotton", "denim", "leather"]}'
  ),
  (
    'cottagecore',
    'Romantic, vintage, nature-inspired. Celebrates rural life, traditional crafts, and pastoral aesthetics.',
    '{"colors": ["cream", "sage", "lavender", "peach", "mint"], "style": "soft", "mood": "whimsical", "keywords": ["vintage", "floral", "romantic", "nature", "handmade"], "patterns": ["floral", "gingham", "lace"], "textures": ["linen", "cotton", "knit"]}'
  ),
  (
    'athleisure',
    'Sporty, comfortable, functional. Athletic wear designed for both workout and casual everyday activities.',
    '{"colors": ["navy", "gray", "white", "black"], "style": "active", "mood": "energetic", "keywords": ["sporty", "comfortable", "functional", "breathable", "stretchy"], "patterns": ["solid", "mesh", "stripe"], "textures": ["technical", "performance", "jersey"]}'
  ),
  (
    'dark-academia',
    'Scholarly, vintage, moody. Inspired by classic literature, gothic architecture, and academia.',
    '{"colors": ["brown", "burgundy", "forest", "navy", "cream"], "style": "classic", "mood": "intellectual", "keywords": ["scholarly", "vintage", "literary", "preppy", "sophisticated"], "patterns": ["plaid", "herringbone", "argyle"], "textures": ["wool", "tweed", "leather"]}'
  ),
  (
    'y2k',
    'Early 2000s nostalgia with futuristic elements. Bright colors, metallics, and playful tech-inspired designs.',
    '{"colors": ["silver", "pink", "blue", "purple"], "style": "retro-futuristic", "mood": "playful", "keywords": ["2000s", "metallic", "butterfly", "tech", "cyber"], "patterns": ["butterfly", "holographic", "abstract"], "textures": ["shiny", "metallic", "synthetic"]}'
  ),
  (
    'bohemian',
    'Free-spirited, eclectic, artistic. Mix of patterns, textures, and global influences with earthy tones.',
    '{"colors": ["terracotta", "mustard", "teal", "rust", "cream"], "style": "eclectic", "mood": "free-spirited", "keywords": ["boho", "artistic", "layered", "ethnic", "natural"], "patterns": ["paisley", "tribal", "mandala", "tie-dye"], "textures": ["macrame", "fringe", "embroidered"]}'
  ),
  (
    'grunge',
    'Alternative, rebellious, anti-fashion. Influenced by 90s rock culture with deliberately unkempt style.',
    '{"colors": ["black", "gray", "burgundy", "olive", "brown"], "style": "alternative", "mood": "rebellious", "keywords": ["edgy", "layered", "vintage", "flannel", "distressed"], "patterns": ["plaid", "distressed", "band-tees"], "textures": ["flannel", "denim", "leather"]}'
  ),
  (
    'coastal-grandmother',
    'Relaxed, sophisticated, breezy. Inspired by coastal living with neutral tones and comfortable elegance.',
    '{"colors": ["white", "navy", "beige", "blue", "sand"], "style": "relaxed-elegant", "mood": "serene", "keywords": ["coastal", "linen", "breezy", "nautical", "timeless"], "patterns": ["stripe", "solid", "subtle-print"], "textures": ["linen", "cotton", "light-knit"]}'
  ),
  (
    'gorpcore',
    'Outdoor utility meets urban fashion. Functional outdoor gear adapted for everyday city wear.',
    '{"colors": ["olive", "brown", "orange", "black", "tan"], "style": "utilitarian", "mood": "adventurous", "keywords": ["outdoor", "functional", "hiking", "utility", "durable"], "patterns": ["solid", "camo", "color-block"], "textures": ["nylon", "gore-tex", "ripstop"]}'
  ),
  (
    'old-money',
    'Timeless, understated luxury. Classic wealth aesthetic with quality over logos and subtle sophistication.',
    '{"colors": ["navy", "cream", "camel", "burgundy", "white"], "style": "refined", "mood": "sophisticated", "keywords": ["timeless", "luxury", "preppy", "tailored", "quality"], "patterns": ["stripe", "solid", "subtle-check"], "textures": ["cashmere", "silk", "wool"]}'
  ),
  (
    'cyberpunk',
    'Futuristic, dystopian, tech-noir. High-tech meets underground culture with neon accents and dark base.',
    '{"colors": ["black", "neon-blue", "neon-pink", "purple"], "style": "futuristic", "mood": "edgy", "keywords": ["tech", "neon", "cybernetic", "dystopian", "futuristic"], "patterns": ["geometric", "circuit", "glitch"], "textures": ["vinyl", "mesh", "reflective"]}'
  ),
  (
    'soft-girl',
    'Cute, gentle, pastel-focused. Sweet and youthful aesthetic with emphasis on soft colors and playful elements.',
    '{"colors": ["pink", "yellow", "blue", "lavender", "peach"], "style": "cute", "mood": "gentle", "keywords": ["cute", "pastel", "sweet", "kawaii", "playful"], "patterns": ["heart", "butterfly", "floral", "gingham"], "textures": ["soft", "fluffy", "cotton"]}'
  ),
  (
    'avant-garde',
    'Experimental, artistic, boundary-pushing. Fashion as art with unconventional silhouettes and concepts.',
    '{"colors": ["black", "white", "red", "gray"], "style": "experimental", "mood": "bold", "keywords": ["artistic", "conceptual", "sculptural", "innovative", "dramatic"], "patterns": ["abstract", "geometric", "asymmetric"], "textures": ["structured", "unconventional", "mixed"]}'
  ),
  (
    'vintage-americana',
    'Nostalgic American workwear and denim culture. Rugged, practical clothing with timeless appeal.',
    '{"colors": ["denim-blue", "red", "white", "khaki", "brown"], "style": "classic-american", "mood": "nostalgic", "keywords": ["denim", "workwear", "vintage", "americana", "rugged"], "patterns": ["denim", "plaid", "stars-stripes"], "textures": ["denim", "canvas", "leather"]}'
  ),
  (
    'balletcore',
    'Graceful, romantic, dance-inspired. Delicate pieces influenced by ballet with feminine silhouettes.',
    '{"colors": ["pink", "white", "lavender", "cream"], "style": "graceful", "mood": "romantic", "keywords": ["ballet", "feminine", "delicate", "wrap", "ribbon"], "patterns": ["solid", "delicate-floral", "lace"], "textures": ["chiffon", "tulle", "satin"]}'
  ),
  (
    'normcore',
    'Deliberately ordinary, anti-fashion fashion. Embracing normal, unpretentious everyday clothing.',
    '{"colors": ["gray", "black", "white", "navy", "khaki"], "style": "ordinary", "mood": "casual", "keywords": ["basic", "simple", "comfortable", "everyday", "practical"], "patterns": ["solid"], "textures": ["cotton", "jersey", "denim"]}'
  ),
  (
    'techwear',
    'High-performance urban wear. Technical fabrics and utility features with sleek, futuristic aesthetic.',
    '{"colors": ["black", "gray", "olive", "dark-blue"], "style": "technical", "mood": "functional", "keywords": ["technical", "utility", "performance", "modular", "urban"], "patterns": ["solid", "tactical"], "textures": ["gore-tex", "nylon", "waterproof"]}'
  ),
  (
    'romantic-academia',
    'Softer take on academia with emphasis on romance and art. Vintage meets ethereal femininity.',
    '{"colors": ["cream", "rose", "sage", "lavender", "gold"], "style": "romantic-scholarly", "mood": "dreamy", "keywords": ["romantic", "vintage", "poetic", "feminine", "artistic"], "patterns": ["floral", "lace", "delicate"], "textures": ["silk", "velvet", "lace"]}'
  ),
  (
    'skater',
    'Laid-back, rebellious, functional. Inspired by skateboard culture with emphasis on movement and style.',
    '{"colors": ["black", "white", "red", "green", "blue"], "style": "casual-rebellious", "mood": "carefree", "keywords": ["skate", "casual", "graphic", "baggy", "streetwise"], "patterns": ["graphic", "stripe", "checkered"], "textures": ["canvas", "denim", "cotton"]}'
  );