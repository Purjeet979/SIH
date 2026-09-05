const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://ganoupqtsujbtrikhiia.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdhbm91cHF0c3VqYnRyaWtoaWlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MjQyMDQsImV4cCI6MjEwNDIwMDIwNH0.tySQFHOj3VMOcEAU469yca_5nYNok0286yYmnC1j6aY'
);

async function testSync() {
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email: 'officer@rulescan.com',
        password: 'Purjeet@9506'
    });
    
    if (authError) {
        console.error("Auth Error:", authError);
        return;
    }
    
    console.log("Logged in!");
    
    // 2. Insert into Products
    const { data: product, error: productError } = await supabase.from('products').insert({
        brand: 'Unknown',
        product_name: 'Scanned Product',
        manufacturer: 'Unknown',
        category: 'Food',
        barcode: null
    }).select().single();
    
    if (productError) {
        console.error("Product Insert Error:", productError);
        return;
    }
    
    console.log("Product Inserted:", product.id);
    
    // 3. Insert into Inspections
    const { data: insp, error: inspError } = await supabase.from('inspections').insert({
        officer_id: authData.user.id,
        product_id: product.id,
        source_type: 'CAMERA',
        category: 'Food',
        overall_status: 'PASS',
        latitude: 0.0,
        longitude: 0.0,
        remarks: ''
    }).select().single();
    
    if (inspError) {
        console.error("Inspection Insert Error:", inspError);
        return;
    }
    
    console.log("Inspection Inserted:", insp.id);
    
    // 4. Insert into Evidence
    const { error: evError } = await supabase.from('evidence').insert({
        inspection_id: insp.id,
        evidence_type: 'ORIGINAL_IMAGE',
        storage_path: 'test_path.jpg'
    });
    
    if (evError) {
        console.error("Evidence Insert Error:", evError);
        return;
    }
    
    console.log("SUCCESS!");
}

testSync();
